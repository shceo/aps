import json
from django.contrib.auth import authenticate, logout
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
            phone = data.get('phone')  # Изменено с username на phone
            password = data.get('password')

            if not phone or not password:
                return JsonResponse(
                    {'message': 'Phone number and password are required', 'status': 'error'},
                    status=400
                )

            # Поиск пользователя по номеру телефона
            try:
                user = Receiver.objects.get(phone=phone)  # В Django `username` может быть телефоном
            except Receiver.DoesNotExist:
                return JsonResponse(
                    {'message': 'User not found', 'status': 'error'},
                    status=404
                )

            # Проверка пароля
            user = authenticate(username=user.username, password=password)

            if user:
                return JsonResponse(
                    {'message': 'Login successful', 'status': 'ok'},
                    status=200
                )
            else:
                return JsonResponse(
                    {'message': 'Invalid phone number or password', 'status': 'error'},
                    status=401
                )

        except json.JSONDecodeError:
            return JsonResponse(
                {'message': 'Invalid JSON format', 'status': 'error'},
                status=400
            )

    return JsonResponse(
        {'message': 'Only POST requests are allowed', 'status': 'error'},
        status=405
    )


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
            phone = data.get('phone')  # Изменено с username на phone
            password = data.get('password')

            if not phone or not password:
                return JsonResponse(
                    {'message': 'Phone number and password are required', 'status': 'error'},
                    status=400
                )

            # Поиск пользователя по номеру телефона
            try:
                user = Branch.objects.get(phone=phone)
            except Branch.DoesNotExist:
                return JsonResponse(
                    {'message': 'User not found', 'status': 'error'},
                    status=404
                )

            user = authenticate(username=user.username, password=password)

            if user:
                return JsonResponse(
                    {'message': 'Login successful', 'status': 'ok'},
                    status=200
                )
            else:
                return JsonResponse(
                    {'message': 'Invalid phone number or password', 'status': 'error'},
                    status=401
                )

        except json.JSONDecodeError:
            return JsonResponse(
                {'message': 'Invalid JSON format', 'status': 'error'},
                status=400
            )

    return JsonResponse(
        {'message': 'Only POST requests are allowed', 'status': 'error'},
        status=405
    )


def logout_view(request):
    if not request.user.is_authenticated:
        return JsonResponse({'message': 'You have to be authenticated to logout from the system',
                             'status': 'error'}, status=400)
    else:
        logout(request)
        return JsonResponse({'message': 'You logged out from the system', 'status': 'ok'}, status=200)


# def registration_view(request):
#     if request.user.is_authenticated:
#         return JsonResponse({'message': f'You are already authenticated as {request.user.username}'},status=200)
#
#
