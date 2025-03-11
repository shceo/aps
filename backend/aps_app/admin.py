from django.contrib import admin

# Register your models here.

@admin.register(Account)
class AccountAdmin(admin.ModelAdmin):
    list_display = ('user', 'is_seller', 'is_customer', 'email', 'phone')
    list_filter = ('is_seller', 'is_customer')
    search_fields = ('user__username', 'email', 'phone')
    ordering = ('user',)