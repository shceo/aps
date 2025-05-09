import json
from pickletools import read_long1

from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
from .models import *
import random
from rest_framework.views import APIView
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

                # === Check if OTP was recently sent ===
                cooldown_key = f"otp_cooldown_{phone}"
                if cache.get(cooldown_key):
                    return JsonResponse({"error": "Please wait 5 minutes before requesting a new code."},
                                        status=status.HTTP_429_TOO_MANY_REQUESTS)

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

                # === Send OTP ===
                otp_code = str(random.randint(100000, 999999))
                OTP.objects.create(phone_number=phone, code=otp_code)

                message = f"SMS-информирование APS Express. Никому не передавайте этот код! Остерегайтесь мошенников! Код: {otp_code}"
                send_sms(phone, message)

                # === Set 5-minute cooldown ===
                cache.set(cooldown_key, True, timeout=300)

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
def get_product_by_category(request, category_id):
    category = get_object_or_404(Category, pk=category_id)
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


def product_translation_list(request):
    products = ProductTranslation.objects.all()

    product_data = [
        {
            'codetved': product.codetved,
            'english': product.english,
            'russian': product.russian,
            'uzbek': product.uzbek,
            'turkish': product.turkish
        }
        for product in products
    ]

    return JsonResponse(product_data, safe=False)



@csrf_exempt
def get_district_by_region(request):
    if request.method == "POST":
        data = json.loads(request.body)
        info = data.get('region')

        if not info:
            return JsonResponse({"error": "Region parameter is missing."}, status=400)

        try:
            region = Region.objects.get(title=info)
        except Region.DoesNotExist:
            return JsonResponse({"error": f"No region named {info}"}, status=404)

        districts = City.objects.filter(region=region)

        district_data = [district.title for district in districts]

        return JsonResponse(district_data, safe=False)

    else:
        return JsonResponse({"error": "Invalid request method. Use POST."}, status=405)






# ========================== User orders tracking ==========================

# @csrf_exempt
# def create_order_tracking(request):
#     if not request.user.is_authenticated:
#         return JsonResponse({"error": "Unauthorized access. Please log in."}, status=401)
#
#     if request.method != "POST":
#         return JsonResponse({"error": "Invalid request method. Use POST."}, status=405)
#
#     try:
#         data = json.loads(request.body)
#
#         # Extract data from the request
#         invoice_no = data.get('invoice_no')
#         order_code = data.get('order_code')
#         created_by = data.get('created_by')
#         sender_name = data.get("sender_name")
#         sender_tel = data.get("sender_tel")
#         receiver_name = data.get("receiver_name")  # Username of the receiver
#         passport = data.get("passport")
#         birth_date = data.get("birth_date")
#         address = data.get("address")
#         product_details = data.get("product_details")
#         brutto = data.get("brutto")
#         total_value = data.get("total_value")
#
#         # Check for required fields
#         if not all([invoice_no, order_code, sender_name, sender_tel, receiver_name, passport, birth_date,
#                     address, product_details, brutto, total_value]):
#             return JsonResponse({"error": "All fields are required."}, status=400)
#
#         # Check if the receiver user exists
#         try:
#             user = Receiver.objects.get(passport_id=passport)
#         except Receiver.DoesNotExist:
#             return JsonResponse({"error": f"User '{receiver_name}' not found."}, status=404)
#
#         # Create a new OrderTracking object
#         order = OrderTracking.objects.create(
#             invoice_no = invoice_no,
#             order_code = order_code,
#             created_by = created_by,
#             sender_name=sender_name,
#             sender_tel=sender_tel,
#             receiver_name=user,
#             passport=passport,
#             birth_date=birth_date,
#             address=address,
#             product_details=product_details,
#             brutto=brutto,
#             total_value=total_value,
#         )
#
#         # Return success response
#         return JsonResponse({
#             "message": "Order tracking created successfully",
#             "order_id": order.id
#         }, status=201)
#
#     except json.JSONDecodeError:
#         return JsonResponse({"error": "Invalid JSON format."}, status=400)
#
#     except Exception as e:
#         return JsonResponse({"error": f"Unexpected error: {str(e)}"}, status=500)


# @csrf_exempt
# def track_user_orders(request):
#     if not request.user.is_authenticated:
#         return JsonResponse({"error": "Unauthorized access. Please log in."}, status=401)
#
#     if request.method != "POST":
#         return JsonResponse({"error": "Invalid request method. Use POST."}, status=405)
#
#     try:
#         data = json.loads(request.body)
#         invoice_no = data.get("invoice_no")
#
#         if not invoice_no:
#             return JsonResponse({"error": "Invoice number is required to fetch tracking details."}, status=400)
#
#         # Filter orders where the user is the receiver
#         orders = OrderTracking.objects.filter(invoice_no=invoice_no)
#
#         if not orders.exists():
#             return JsonResponse({"error": "No orders found for this invoice number."}, status=404)
#
#         order_data = [
#             {
#                 "id": order.id,
#                 "invoice_number": order.invoice_no,
#                 "order_code": order.order_code,
#                 "created_by": order.created_by,
#                 "sender_name": order.sender_name,
#                 "sender_tel": order.sender_tel,
#                 "receiver_name": order.receiver.receiver.username if order.receiver.receiver else "No User",
#                 "receiver_phone": order.receiver.phone,
#                 "passport": order.passport,
#                 "birth_date": order.birth_date,
#                 "address": order.address,
#                 "product_details": order.product_details,
#                 "brutto": float(order.brutto),
#                 "total_value": float(order.total_value),
#                 "created_at": order.created_at.strftime("%Y-%m-%d %H:%M:%S"),
#             }
#             for order in orders
#         ]
#
#         return JsonResponse({"orders": order_data}, status=200)
#
#     except json.JSONDecodeError:
#         return JsonResponse({"error": "Invalid JSON format."}, status=400)
#
#     except Exception as e:
#         return JsonResponse({"error": f"Unexpected error: {str(e)}"}, status=500)



# def get_district_by_city(request):
#     if request.method != 'POST':
#         return JsonResponse({"error": "Only POST method is allowed"}, status=405)
#
#     try:
#         data = json.loads(request.body)
#     except json.JSONDecodeError:
#         return JsonResponse({"error": "Invalid JSON format"}, status=400)
#
#     city_json = data.get('city')
#
#     if not city_json:
#         return JsonResponse({"error": "Sending city is required"}, status=400)
#
#     try:
#         city = City.objects.get(city__iexact=city_json.strip())
#     except City.DoesNotExist:
#         return JsonResponse({"error": f"No city by name '{city_json}' found. Enter a valid name."}, status=404)
#
#     regions = Region.objects.filter(region=city)
#
#     serializer = RegionSerializer(regions, many=True)
#     return JsonResponse(serializer.data, safe=False)



# import requests
#
# YANDEX_API_KEY = 'cfeaf66a-7a1d-4296-b1cd-f1417ca9adbd'
#
# @csrf_exempt
# def validate_address(request):
#     if request.method == 'POST':
#         address = request.POST.get('address') or json.loads(request.body).get('address')
#
#         if not address:
#             return JsonResponse({'error': 'Address not provided'}, status=400)
#
#         url = 'https://geocode-maps.yandex.ru/1.x/'
#         params = {
#             'apikey': YANDEX_API_KEY,
#             'geocode': address,
#             'format': 'json'
#         }
#
#         response = requests.get(url, params=params)
#         data = response.json()
#
#         try:
#             feature = data['response']['GeoObjectCollection']['featureMember']
#             if not feature:
#                 return JsonResponse({'valid': False})
#
#             address_data = feature[0]['GeoObject']['metaDataProperty']['GeocoderMetaData']['Address']['Components']
#             components = {c['kind']: c['name'] for c in address_data}
#
#             print(components, '====================================')
#             print(address_data)
#             return JsonResponse({
#                 'valid': True,
#                 'country': components.get('country'),
#                 'region': components.get('province'),
#                 'district': components.get('district'),
#                 'street': components.get('street'),
#                 'house': components.get('house')
#             })
#
#
#         except Exception as e:
#             return JsonResponse({'error': 'Error processing address'}, status=500)
#     return None






