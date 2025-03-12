import json
from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from .models import Branch, Receiver

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


@csrf_exempt  # Add CSRF exemption for logout
def logout_view(request):
    if not request.user.is_authenticated:
        return JsonResponse(
            {'message': 'You have to be authenticated to logout from the system', 'status': 'error'}, status=400
        )
    else:
        logout(request)
        return JsonResponse({'message': 'You logged out from the system', 'status': 'ok'}, status=200)



@csrf_exempt
def registration_view(request):
    if request.user.is_authenticated:
        return JsonResponse({'message': f'You are already authenticated as {request.user.username}'}, status=200)

    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            first_name = data.get('first_name')
            phone = data.get('phone')
            password1 = data.get('pass1')
            password2 = data.get('pass2')

            if not first_name or not phone or not password1 or not password2:
                return JsonResponse({'message': 'Please enter all required fields', 'status': 'error'}, status=400)

            if password1 != password2:
                return JsonResponse({'message': 'Passwords do not match', 'status': 'error'}, status=400)

            if Receiver.objects.filter(phone=phone).exists():
                return JsonResponse({'message': 'Phone number is already registered', 'status': 'error'}, status=400)

            try:
                user = User.objects.create_user(username=phone, password=password1, first_name=first_name)
                receiver = Receiver.objects.create(receiver=user, phone=phone)

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



















