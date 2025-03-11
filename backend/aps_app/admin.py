from django.contrib import admin
from .models import *

# Register your models here.

@admin.register(Branch)
class BranchAdmin(admin.ModelAdmin):
    list_display = ('seller', 'email', 'phone')
    search_fields = ('seller__username', 'email', 'phone')
    ordering = ('seller',)

@admin.register(Receiver)
class ReceiverAdmin(admin.ModelAdmin):
    list_display = ('receiver', 'email', 'phone')
    search_fields = ('receiver__username', 'email', 'phone')
    ordering = ('receiver',)