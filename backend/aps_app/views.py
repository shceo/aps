import json
from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from .models import *
import random
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import *
from .eskiz_utils import send_sms
from django.utils.decorators import method_decorator
from django.core.cache import cache
import re




@csrf_exempt
def login_view(request):
    if request.user.is_authenticated:
        return JsonResponse(
            {'message': f'You are already authenticated as {request.user.username}'},
            status=200
        )

    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            phone = data.get('phone')
            password = data.get('password')

            if not phone or not password:
                return JsonResponse(
                    {'message': 'Phone number and password are required', 'status': 'error'},
                    status=400
                )

            # Find user by phone
            try:
                receiver = Receiver.objects.get(phone=phone)
                user = receiver.receiver  # Get User instance
            except Receiver.DoesNotExist:
                return JsonResponse({'message': 'User not found', 'status': 'error'}, status=404)

            # Authenticate user
            user = authenticate(username=user.username, password=password)

            if user:
                login(request, user)  # Log the user in
                return JsonResponse({'message': 'Login successful', 'status': 'ok'}, status=200)
            else:
                return JsonResponse({'message': 'Invalid phone number or password', 'status': 'error'}, status=401)

        except json.JSONDecodeError:
            return JsonResponse({'message': 'Invalid JSON format', 'status': 'error'}, status=400)

    return JsonResponse({'message': 'Only POST requests are allowed', 'status': 'error'}, status=405)


@csrf_exempt
def login_view_admin(request):
    if request.user.is_authenticated:
        return JsonResponse(
            {'message': f'You are already authenticated as {request.user.username}'},
            status=200
        )

    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            phone = data.get('phone')
            password = data.get('password')

            if not phone or not password:
                return JsonResponse(
                    {'message': 'Phone number and password are required', 'status': 'error'},
                    status=400
                )

            try:
                branch = Branch.objects.get(phone=phone)
                user = branch.seller  # Get related User instance
            except Branch.DoesNotExist:
                return JsonResponse({'message': 'User not found', 'status': 'error'}, status=404)

            # Authenticate user
            user = authenticate(username=user.username, password=password)

            if user:
                login(request, user)  # Log the admin in
                return JsonResponse({'message': 'Login successful', 'status': 'ok'}, status=200)
            else:
                return JsonResponse({'message': 'Invalid phone number or password', 'status': 'error'}, status=401)

        except json.JSONDecodeError:
            return JsonResponse({'message': 'Invalid JSON format', 'status': 'error'}, status=400)

    return JsonResponse({'message': 'Only POST requests are allowed', 'status': 'error'}, status=405)


@csrf_exempt
def logout_view(request):
    if not request.user.is_authenticated:
        return JsonResponse(
            {'message': 'You have to be authenticated to logout from the system', 'status': 'error'}, status=400
        )
    else:
        logout(request)
        return JsonResponse({'message': 'You logged out from the system', 'status': 'ok'}, status=200)


@method_decorator(csrf_exempt, name='dispatch')
class RegistrationView(APIView):

    def post(self, request):
        if request.user.is_authenticated:
            return JsonResponse({"error": "User is already logged in."}, status=status.HTTP_400_BAD_REQUEST)

        if 'code' not in request.data or request.data.get('code') == '':
            serializer = RegistrationSerializer(data=request.data)
            if serializer.is_valid():
                phone = serializer.validated_data.get('phone_number')
                first_name = serializer.validated_data.get('first_name')
                password = serializer.validated_data.get('password')

                cache.set(f"otp_password_{phone}", password, timeout=300)
                cache.set(f"otp_first_name_{phone}", first_name, timeout=300)

                if not self.is_valid_uzbek_phone_number(phone):
                    return JsonResponse({"error": "Invalid Uzbek phone number format. Example: +998971233322."},
                                    status=status.HTTP_400_BAD_REQUEST)

                if User.objects.filter(username=phone).exists():
                    return JsonResponse({"error": "This phone number is already registered. Please log in."},
                                    status=status.HTTP_400_BAD_REQUEST)

                # Generate OTP and send it
                otp_code = str(random.randint(100000, 999999))
                OTP.objects.create(phone_number=phone, code=otp_code)
                message = f"Сообщение от APS Express. Никому не передавайте этот код! Остерегайтесь мошенников! Код: {otp_code}"
                send_sms(phone, message)

                return JsonResponse({"message": "Verification code sent successfully."}, status=status.HTTP_200_OK)

            return JsonResponse(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        else:
            serializer = OTPVerificationSerializer(data=request.data)
            if serializer.is_valid():
                phone = serializer.validated_data.get('phone_number')
                code = serializer.validated_data.get('code')

                try:
                    otp = OTP.objects.filter(phone_number=phone, code=code).latest('created_at')
                    if otp.is_expired():
                        return JsonResponse({"error": "OTP expired."}, status=status.HTTP_400_BAD_REQUEST)

                    if User.objects.filter(username=phone).exists():
                        return JsonResponse({"error": "This phone number is already registered. Please log in."},
                                        status=status.HTTP_400_BAD_REQUEST)

                    password = cache.get(f"otp_password_{phone}")
                    first_name = cache.get(f"otp_first_name_{phone}")

                    if not password or not first_name:
                        return JsonResponse({"error": "Your session has expired. Please register again."}, status=400)

                    user = User.objects.create_user(username=phone, password=password)
                    user.first_name = first_name
                    user.save()
                    Receiver.objects.create(receiver=user, phone=phone)
                    login(request, user)

                    return JsonResponse({"message": "User registered successfully!"}, status=status.HTTP_201_CREATED)

                except OTP.DoesNotExist:
                    return JsonResponse({"error": "Invalid OTP."}, status=status.HTTP_400_BAD_REQUEST)

            return JsonResponse(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def is_valid_uzbek_phone_number(self, phone):
        pattern = re.compile(r"^\+998\d{9}$")
        return bool(pattern.match(phone))


@csrf_exempt
def admin_registration_view(request):
    if request.user.is_authenticated:
        return JsonResponse({'message': f'You are already authenticated as {request.user.username}'}, status=200)

    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            first_name = data.get('first_name')
            phone = data.get('phone')
            password1 = data.get('password')
            password2 = data.get('password_confirm')

            if not first_name or not phone or not password1 or not password2:
                return JsonResponse({'message': 'Please enter all required fields', 'status': 'error'}, status=400)

            if password1 != password2:
                return JsonResponse({'message': 'Passwords do not match', 'status': 'error'}, status=400)

            if Receiver.objects.filter(phone=phone).exists():
                return JsonResponse({'message': 'Phone number is already registered', 'status': 'error'}, status=400)

            try:
                user = User.objects.create_user(username=phone, password=password1, first_name=first_name)
                receiver = Branch.objects.create(seller=user, phone=phone)

                user = authenticate(username=phone, password=password1)
                if user:
                    login(request, user)
                    return JsonResponse({'message': 'Registration successful', 'status': 'success'}, status=201)

                return JsonResponse({'message': 'Authentication failed after registration', 'status': 'error'}, status=500)

            except Exception as e:
                return JsonResponse({'message': f'Error occurred while saving to the database: {str(e)}', 'status': 'error'}, status=500)

        except json.JSONDecodeError:
            return JsonResponse({'message': 'Invalid JSON format', 'status': 'error'}, status=400)

    return JsonResponse({'message': 'Only POST requests are allowed', 'status': 'error'}, status=405)

@csrf_exempt
def register_fcm_token(request):
    if request.method == "POST":
        data = json.loads(request.body)
        user_id = data.get("user_id")
        fcm_token = data.get("fcm_token")

        if not user_id or not fcm_token:
            return JsonResponse({"error": "Missing user_id or fcm_token"}, status=400)

        try:
            user = User.objects.get(id=user_id)
            device, created = UserDevice.objects.update_or_create(user=user, defaults={"fcm_token": fcm_token})
            return JsonResponse({"message": "FCM Token registered successfully"})
        except User.DoesNotExist:
            return JsonResponse({"error": "User not found"}, status=404)

    return JsonResponse({"error": "Invalid request"}, status=400)


# from .firebase_helper import send_push_notification

def send_user_notification(request, user_id):
    try:
        device = UserDevice.objects.get(user_id=user_id)
        token = device.fcm_token
        response = send_push_notification(token, "Hello!", "This is a test notification.")
        return JsonResponse({"message": "Notification sent", "response": response})
    except UserDevice.DoesNotExist:
        return JsonResponse({"error": "User not found or no device registered"}, status=404)


# ============================ Products and Orders ==================================

def get_all_products(request):
    products = Product.objects.all()

    products_data = []
    for product in products:
        products_data.append({
            'id': product.id,
            'title': product.title,
            'description': product.description,
            'price': float(product.price),
            'quantity': product.quantity,
            'size': product.size,
            'category': product.category.title,
            'slug': product.slug,
            'model': product.model.title if product.model else None,
            'discount': product.discount,
            'created_at': product.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            'updated_at': product.updated_at.strftime('%Y-%m-%d %H:%M:%S'),
            'image': product.get_first_photo(),
        })

    return JsonResponse({'products': products_data}, safe=False)

# ✅ Get a single product by ID
def get_single_product(request, product_id):
    product = get_object_or_404(Product, id=product_id)

    product_data = {
        'id': product.id,
        'title': product.title,
        'description': product.description,
        'price': float(product.price),
        'quantity': product.quantity,
        'size': product.size,
        'category': product.category.title,
        'slug': product.slug,
        'model': product.model.title if product.model else None,
        'discount': product.discount,
        'created_at': product.created_at.strftime('%Y-%m-%d %H:%M:%S'),
        'updated_at': product.updated_at.strftime('%Y-%m-%d %H:%M:%S'),
        'image': product.get_first_photo(),
    }

    return JsonResponse({'product': product_data}, safe=False)

# ✅ Get products by category
def get_product_by_category(request, slug):
    category = get_object_or_404(Category, slug=slug)
    products = Product.objects.filter(category=category)

    products_data = []
    for product in products:
        products_data.append({
            'id': product.id,
            'title': product.title,
            'description': product.description,
            'price': float(product.price),
            'quantity': product.quantity,
            'size': product.size,
            'category': product.category.title,
            'slug': product.slug,
            'model': product.model.title if product.model else None,
            'discount': product.discount,
            'created_at': product.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            'updated_at': product.updated_at.strftime('%Y-%m-%d %H:%M:%S'),
            'image': product.get_first_photo(),
        })

    return JsonResponse({'category': category.title, 'products': products_data}, safe=False)


# ========================== User orders tracking ==========================

@csrf_exempt
def create_order_tracking(request):
    if not request.user.is_authenticated:
        return JsonResponse({"error": "Unauthorized access. Please log in."}, status=401)

    if request.method != "POST":
        return JsonResponse({"error": "Invalid request method. Use POST."}, status=405)

    try:
        data = json.loads(request.body)

        # Extract data from the request
        invoice_no = data.get('invoice_no')
        order_code = data.get('order_code')
        created_by = data.get('created_by')
        sender_name = data.get("sender_name")
        sender_tel = data.get("sender_tel")
        receiver_name = data.get("receiver_name")  # Username of the receiver
        passport = data.get("passport")
        birth_date = data.get("birth_date")
        address = data.get("address")
        product_details = data.get("product_details")
        brutto = data.get("brutto")
        total_value = data.get("total_value")

        # Check for required fields
        if not all([invoice_no, order_code, sender_name, sender_tel, receiver_name, passport, birth_date,
                    address, product_details, brutto, total_value]):
            return JsonResponse({"error": "All fields are required."}, status=400)

        # Check if the receiver user exists
        try:
            user = Receiver.objects.get(passport_id=passport)
        except Receiver.DoesNotExist:
            return JsonResponse({"error": f"User '{receiver_name}' not found."}, status=404)

        # Create a new OrderTracking object
        order = OrderTracking.objects.create(
            invoice_no = invoice_no,
            order_code = order_code,
            created_by = created_by,
            sender_name=sender_name,
            sender_tel=sender_tel,
            receiver_name=user,
            passport=passport,
            birth_date=birth_date,
            address=address,
            product_details=product_details,
            brutto=brutto,
            total_value=total_value,
        )

        # Return success response
        return JsonResponse({
            "message": "Order tracking created successfully",
            "order_id": order.id
        }, status=201)

    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON format."}, status=400)

    except Exception as e:
        return JsonResponse({"error": f"Unexpected error: {str(e)}"}, status=500)





@csrf_exempt
def track_user_orders(request):
    if not request.user.is_authenticated:
        return JsonResponse({"error": "Unauthorized access. Please log in."}, status=401)

    if request.method != "POST":
        return JsonResponse({"error": "Invalid request method. Use POST."}, status=405)

    try:
        data = json.loads(request.body)
        invoice_no = data.get("invoice_no")

        if not invoice_no:
            return JsonResponse({"error": "Invoice number is required to fetch tracking details."}, status=400)

        # Filter orders where the user is the receiver
        orders = OrderTracking.objects.filter(invoice_no=invoice_no)

        if not orders.exists():
            return JsonResponse({"error": "No orders found for this invoice number."}, status=404)

        order_data = [
            {
                "id": order.id,
                "invoice_number": order.invoice_no,
                "order_code": order.order_code,
                "created_by": order.created_by,
                "sender_name": order.sender_name,
                "sender_tel": order.sender_tel,
                "receiver_name": order.receiver.receiver.username if order.receiver.receiver else "No User",
                "receiver_phone": order.receiver.phone,
                "passport": order.passport,
                "birth_date": order.birth_date,
                "address": order.address,
                "product_details": order.product_details,
                "brutto": float(order.brutto),
                "total_value": float(order.total_value),
                "created_at": order.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            }
            for order in orders
        ]

        return JsonResponse({"orders": order_data}, status=200)

    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON format."}, status=400)

    except Exception as e:
        return JsonResponse({"error": f"Unexpected error: {str(e)}"}, status=500)






