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
    search_fields = ('user_username',)
    ordering = ('user',)

