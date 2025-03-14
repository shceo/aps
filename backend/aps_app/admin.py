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
    list_display = ('receiver', 'phone')
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


@admin.register(ImageProduct)
class ImageProductAdmin(admin.ModelAdmin):
    list_display = ('product', 'image')
    search_fields = ('product__title',)
    list_filter = ('product',)


