from django.urls import path
from .views import *

urlpatterns = [
    path('api_login/', login_view, name='login')
]
