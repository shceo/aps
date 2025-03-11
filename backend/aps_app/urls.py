from django.urls import path
from .views import *

urlpatterns = [
    path('login/', login_view, name='login'),
    path('login/admin/', login_view_admin, name='login_admin'),
    path('logout/', logout_view, name='logout')
]
