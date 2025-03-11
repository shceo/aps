from django.db import models

# Create your models here.


class Account(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, verbose_name='User')
    is_seller = models.BooleanField(default=False, verbose_name='Отправитель')
    is_customer = models.BooleanField(default=True, verbose_name='Получатель')
    email = models.EmailField(null=True, blank=True, verbose_name='Email')
    phone = models.CharField(max_length=20, null=True, blank=True, verbose_name='Телефон')

    class Meta:
        verbose_name = "Аккаунт"
        verbose_name_plural = "Аккаунты"
        ordering = ['user']  # Orders by user

    def __str__(self):
        return f"{self.user.username} ({'Seller' if self.is_seller else 'Customer'})"

