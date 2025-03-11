from django.db import models
from django.contrib.auth.models import User

class Branch(models.Model):
    seller = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, verbose_name='Seller')
    email = models.EmailField(null=True, blank=True, verbose_name='Email')
    phone = models.CharField(max_length=20, null=True, blank=True, verbose_name='Телефон')

    class Meta:
        verbose_name = "Филиал"
        verbose_name_plural = "Филиалы"
        ordering = ['seller']

    def __str__(self):
        return f"{self.seller if self.seller else 'No user'}"


class Receiver(models.Model):
    receiver = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, verbose_name='User')
    email = models.EmailField(null=True, blank=True, verbose_name='Email')
    phone = models.CharField(max_length=20, null=True, blank=True, verbose_name='Телефон')

    class Meta:
        verbose_name = "Получатель"
        verbose_name_plural = "Получатели"
        ordering = ['receiver']

    def __str__(self):
        return f"{self.receiver.username if self.user else 'No User'}"
