from django.contrib import admin
from .models import *

# Register your models here.

@admin.register(Branch)
class BranchAdmin(admin.ModelAdmin):
    list_display = ('seller', 'phone')
    search_fields = ('seller__username', 'phone')
    ordering = ('seller',)

@admin.register(Receiver)
class ReceiverAdmin(admin.ModelAdmin):
    list_display = ('receiver', 'phone', 'passport_id')
    search_fields = ('receiver__username', 'phone')
    ordering = ('receiver',)

@admin.register(UserDevice)
class UserDeviceAdmin(admin.ModelAdmin):
    list_display = ('user', 'fcm_token')
    search_fields = ('user__username',)
    ordering = ('user',)


# ================== Products ============================


from django.contrib import admin
from django.utils.text import slugify
from .models import Category, Brand, Product, ImageProduct


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('title', 'parent', 'slug')
    search_fields = ('title',)
    prepopulated_fields = {'slug': ('title',)}
    list_filter = ('parent',)


@admin.register(Brand)
class BrandAdmin(admin.ModelAdmin):
    list_display = ('title', 'created_at')
    search_fields = ('title',)
    ordering = ('-created_at',)


class ImageProductInline(admin.TabularInline):  # Inline images for Product
    model = ImageProduct
    extra = 1  # Allows adding extra image fields


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('title', 'price', 'quantity', 'category', 'model', 'discount', 'created_at')
    search_fields = ('title', 'description', 'category__title', 'model__title')
    list_filter = ('category', 'model', 'discount')
    prepopulated_fields = {'slug': ('title',)}
    readonly_fields = ('created_at', 'updated_at')
    inlines = [ImageProductInline]  # Allows adding images directly in the product admin
    ordering = ('-created_at',)
    autocomplete_fields = ('category', 'model')  # Optimizes dropdown fields for large datasets

    def save_model(self, request, obj, form, change):
        """Automatically generate slug if not provided"""
        if not obj.slug:
            obj.slug = slugify(obj.title)
        super().save_model(request, obj, form, change)


@admin.register(OrderMoneyLimit)
class OrderMoneyLimitAdmin(admin.ModelAdmin):
    list_display = ('customer', 'limit', 'created_at')  # Columns in the admin panel
    search_fields = ('customer__receiver__username',)  # Enable search by username
    list_filter = ('created_at',)  # Filter by creation date


@admin.register(OrderAdmin)
class OrderAdminAdmin(admin.ModelAdmin):
    list_display = ('customer', 'full_price', 'created_at')  # Show these fields
    search_fields = ('customer__receiver__username', 'passport_id')  # Enable search
    list_filter = ('created_at',)  # Add filters
    ordering = ('-created_at',)  # Sort by newest orders first


# @admin.register(OrderProduct)
# class OrderProductAdmin(admin.ModelAdmin):
#     list_display = ('pk', 'order', 'product', 'quantity', 'added_at', 'updated_at', 'get_total_price')
#     list_filter = ('order', 'product')
#     search_fields = ('order__pk', 'product__title')
#     readonly_fields = ('added_at', 'updated_at', 'get_total_price')
#
#     def get_total_price(self, obj):
#         return obj.get_total_price
#
#     get_total_price.short_description = "Стоимость товара в заказе"
#
#
# @admin.register(ShippingAddress)
# class ShippingAddressAdmin(admin.ModelAdmin):
#     list_display = ('pk', 'customer', 'order', 'address', 'phone', 'region', 'city', 'created_at')
#     list_filter = ('region', 'city')
#     search_fields = (
#     'customer__user__username', 'customer__user__first_name', 'customer__user__last_name', 'address', 'phone')
#     readonly_fields = ('created_at',)


@admin.register(Region)
class RegionAdmin(admin.ModelAdmin):
    list_display = ('pk', 'title')
    search_fields = ('title',)


@admin.register(City)
class CityAdmin(admin.ModelAdmin):
    list_display = ('pk', 'title', 'region')
    search_fields = ('title', 'region__title')
    list_filter = ('region',)


# ============== ORDER TRACKING =================

@admin.register(OrderTracking)
class OrderTrackingAdmin(admin.ModelAdmin):
    list_display = (
        'invoice_no',
        'order_code',
        'sender_name',
        'receiver',
        'formatted_birth_date',  # ← custom method
        'brutto',
        'total_value',
        'created_at'
    )

    def formatted_birth_date(self, obj):
        return obj.birth_date.strftime("%d-%m-%Y")
    formatted_birth_date.short_description = "Birth Date"

    search_fields = ('invoice_no','order_code','sender_name','receiver','passport',)

    list_filter = ('created_at', 'receiver')
    readonly_fields = ('created_at', 'updated_at')

    fieldsets = (
        ('Order Info', {
            'fields': ('invoice_no', 'order_code', 'sender_name', 'sender_tel', 'receiver')
        }),
        ('Receiver Details', {
            'fields': ('passport', 'birth_date', 'address')
        }),
        ('Product Info', {
            'fields': ('product_details', 'brutto', 'total_value')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )

