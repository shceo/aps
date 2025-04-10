from django.urls import path
from .views import *

urlpatterns = [
    path('login/', login_view, name='login'),
    path('login/admin/', login_view_admin, name='login_admin'),
    path('logout/', logout_view, name='logout'),
    path('reg/', RegistrationView.as_view(), name='reg'),
    path('reg/admin/', admin_registration_view, name='reg_admin'),

    # ===== Notifications =============
    path("register_fcm_token/", register_fcm_token, name="register_fcm_token"),
    path("send_notification/<int:user_id>/", send_user_notification, name="send_notification"),

    # ===== Products ===================

    path('products/', get_all_products, name='get_all_products'),
    path('products/<int:product_id>/', get_single_product, name='get_single_product'),
    path("product_by_category/<slug:slug>/", get_product_by_category, name='product_by_category'),


    # ===== ORDER TRACKING =============
    path('create_order_tracking/', create_order_tracking, name='create_o_t'),
    path('order_tracking/', track_user_orders, name='order_track'),

    # ===== OTP VIA SMS ================

    # path('send-otp/', SendOTPView.as_view, name='send_otp'),
    # path('verify-otp/', VerifyOTPView.as_view, name='verify_otp'),
]
