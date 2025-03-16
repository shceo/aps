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


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('pk', 'customer', 'created_at', 'is_completed', 'payment', 'shipping', 'get_order_total_price',
                    'get_order_total_quantity')
    list_filter = ('is_completed', 'payment', 'shipping', 'created_at')
    search_fields = ('customer__user__username', 'customer__user__first_name', 'customer__user__last_name')
    readonly_fields = ('created_at', 'get_order_total_price', 'get_order_total_quantity')

    def get_order_total_price(self, obj):
        return obj.get_order_total_price

    get_order_total_price.short_description = "Общая сумма заказа"

    def get_order_total_quantity(self, obj):
        return obj.get_order_total_quantity

    get_order_total_quantity.short_description = "Общее количество товаров"


@admin.register(OrderProduct)
class OrderProductAdmin(admin.ModelAdmin):
    list_display = ('pk', 'order', 'product', 'quantity', 'added_at', 'updated_at', 'get_total_price')
    list_filter = ('order', 'product')
    search_fields = ('order__pk', 'product__title')
    readonly_fields = ('added_at', 'updated_at', 'get_total_price')

    def get_total_price(self, obj):
        return obj.get_total_price

    get_total_price.short_description = "Стоимость товара в заказе"


@admin.register(ShippingAddress)
class ShippingAddressAdmin(admin.ModelAdmin):
    list_display = ('pk', 'customer', 'order', 'address', 'phone', 'region', 'city', 'created_at')
    list_filter = ('region', 'city')
    search_fields = (
    'customer__user__username', 'customer__user__first_name', 'customer__user__last_name', 'address', 'phone')
    readonly_fields = ('created_at',)


@admin.register(Region)
class RegionAdmin(admin.ModelAdmin):
    list_display = ('pk', 'title')
    search_fields = ('title',)


@admin.register(City)
class CityAdmin(admin.ModelAdmin):
    list_display = ('pk', 'title', 'region')
    search_fields = ('title', 'region__title')
    list_filter = ('region',)

