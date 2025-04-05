from django.contrib.auth.models import User
from django.db import models
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.urls import reverse
from django.core.validators import MinLengthValidator, MaxLengthValidator, MinValueValidator
from django.utils.translation import gettext_lazy as _


class Branch(models.Model):
    seller = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, verbose_name='Seller')
    phone = models.CharField(max_length=20, null=True, blank=True, verbose_name='Телефон')

    class Meta:
        verbose_name = "Филиал"
        verbose_name_plural = "Филиалы"
        ordering = ['seller']

    def __str__(self):
        return f"{self.seller if self.seller else 'No user'}"


class Receiver(models.Model):
    receiver = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, verbose_name='User')
    phone = models.CharField(max_length=20, null=True, blank=True, verbose_name='Телефон')
    passport_id = models.CharField(max_length=20, null=True, blank=True, verbose_name='Паспорт ID')


    class Meta:
        verbose_name = "Получатель"
        verbose_name_plural = "Получатели"
        ordering = ['receiver']

    def __str__(self):
        return f"{self.receiver.username if self.receiver else 'No User'}"


# =============================  For Notifications ===================================

class UserDevice(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    fcm_token = models.CharField(max_length=255, unique=True)

    class Meta:
        verbose_name = 'Устройство пользователя'
        verbose_name_plural = 'Устройство пользователей'



# ================ Products ==========================



class Category(models.Model):
    title = models.CharField(max_length=100, verbose_name='Название категории')
    slug = models.SlugField(unique=True, blank=True, null=True, verbose_name='Слаг категории')
    parent = models.ForeignKey(
        'self', on_delete=models.SET_NULL, null=True, blank=True,
        related_name='subcategories', verbose_name='Категория'
    )

    def __str__(self):
        return self.title

    class Meta:
        ordering = ['title']
        verbose_name = 'Категория'
        verbose_name_plural = 'Категории'


class Brand(models.Model):
    title = models.CharField(max_length=150, verbose_name='Модель товара')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата добавления')

    def __str__(self):
        return self.title

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Бренд'
        verbose_name_plural = 'Бренды'


class Product(models.Model):
    title = models.CharField(max_length=200, verbose_name='Название товара')
    description = models.TextField(
        verbose_name='Описание товара',
        validators=[MinLengthValidator(100), MaxLengthValidator(500)]
    )
    short_description = models.TextField(
        verbose_name='Краткое описание',
        validators=[MinLengthValidator(10), MaxLengthValidator(100)],
        default="Описание отсутствует."  # Default text for existing rows
    )
    price = models.FloatField(verbose_name='Цена товара')
    quantity = models.PositiveIntegerField(default=0, verbose_name='Количество')
    size = models.CharField(max_length=10, blank=True, null=True, verbose_name='Размер')
    category = models.ForeignKey(Category, on_delete=models.CASCADE, verbose_name='Категория товара')
    slug = models.SlugField(unique=True, blank=True, null=True, verbose_name='Слаг товара')
    model = models.ForeignKey(Brand, on_delete=models.CASCADE, blank=True, null=True, verbose_name='Модель')
    discount = models.PositiveIntegerField(blank=True, null=True, verbose_name='Скидка')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата добавление')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Дата Изменение')

    def get_absolute_url(self):
        return reverse('product', kwargs={'pk': self.pk})

    def get_first_photo(self):
        first_image = self.images.first()
        return first_image.image.url if first_image else None

    def __str__(self):
        return self.title or 'No name'

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Товар'
        verbose_name_plural = 'Товары'



class ImageProduct(models.Model):
    image = models.ImageField(upload_to='images/', verbose_name='Фото товара')
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='images', verbose_name='Товар')

    def __str__(self):
        return self.product.title if self.product else 'No product'

    class Meta:
        ordering = ['id']
        verbose_name = 'Изображение товара'
        verbose_name_plural = 'Изображения товаров'



class OrderMoneyLimit(models.Model):
    customer = models.ForeignKey(
        Receiver, on_delete=models.SET_NULL, null=True, verbose_name='Покупатель', related_name='money_limits'
    )
    limit = models.FloatField(default=0, verbose_name='Лимит на $1000')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')

    def reset_limit(self):
        """Resets limit every 3 months."""
        self.limit = 0
        self.save()

    def __str__(self):
        return f"Лимит {self.customer.receiver.username}: {self.limit}"

    class Meta:
        verbose_name = 'Лимит на заказ'
        verbose_name_plural = 'Лимиты на заказы'


class OrderAdmin(models.Model):
    region = models.ForeignKey('Region', on_delete=models.SET_NULL, null=True, verbose_name='Регион')
    city = models.ForeignKey('City', on_delete=models.SET_NULL, null=True, verbose_name='Город')

    street = models.TextField(verbose_name='Улица', validators=[MaxLengthValidator(150)])

    customer = models.ForeignKey(
        Receiver, on_delete=models.SET_NULL, null=True, verbose_name='Покупатель', related_name='orders'
    )
    weight = models.FloatField(default=0, verbose_name='Вес заказа')
    full_price = models.FloatField(verbose_name='Общая сумма')

    limit = models.ForeignKey(OrderMoneyLimit, on_delete=models.SET_NULL, null=True, blank=True, verbose_name="Лимит")
    passport_id = models.CharField(max_length=10, verbose_name='Серия паспорта')
    dof = models.CharField(verbose_name='Дата рождение', max_length=20)

    notes = models.TextField(verbose_name='Заметки', validators=[MaxLengthValidator(200)])

    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата заказа')

    def __str__(self):
        return f'Номер заказа: {self.pk}, на имя: {self.customer.receiver.username}'

    class Meta:
        verbose_name = 'Заказ'
        verbose_name_plural = 'Заказы'


# Signal to automatically update the limit when an order is created
@receiver(post_save, sender=OrderAdmin)
def update_customer_limit(sender, instance, created, **kwargs):
    if instance.customer:
        money_limit, created = OrderMoneyLimit.objects.get_or_create(customer=instance.customer)

        # Add order's price to the customer's limit
        money_limit.limit += instance.full_price
        money_limit.save()


class OrderProduct(models.Model):
    product = models.ForeignKey(
        Product, on_delete=models.SET_NULL, null=True, verbose_name='Товар', related_name='order_products'
    )
    order = models.ForeignKey(
        OrderAdmin, on_delete=models.SET_NULL, null=True, verbose_name='Заказ', related_name='order_products'
    )
    quantity = models.IntegerField(default=0, verbose_name='В количестве')
    added_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата добавления')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Дата изменения')

    def __str__(self):
        return f'Товар {self.product.title} по заказу №: {self.order.pk}'

    class Meta:
        verbose_name = 'Заказанный товар'
        verbose_name_plural = 'Заказанные товары'

    @property
    def get_total_price(self):
        price = self.product.price
        if self.product.discount:
            discount_amount = (price * self.product.discount) / 100
            price -= discount_amount
        return price * self.quantity

#
# class ShippingAddress(models.Model):
#     customer = models.ForeignKey(
#         Receiver, on_delete=models.SET_NULL, null=True, verbose_name='Покупатель', related_name='shipping_addresses'
#     )
#     order = models.ForeignKey(
#         Order, on_delete=models.SET_NULL, null=True, verbose_name='Заказ', related_name='shipping_addresses'
#     )
#     address = models.CharField(max_length=150, verbose_name='Адрес доставки (улица, дом, кв)')
#     phone = models.CharField(max_length=30, verbose_name='Номер телефона')
#     comment = models.TextField(verbose_name='Комментарий к заказу', max_length=200)
#     created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата оформления доставки')
#     region = models.ForeignKey('Region', on_delete=models.SET_NULL, null=True, verbose_name='Регион', related_name='addresses')
#     city = models.ForeignKey('City', on_delete=models.SET_NULL, null=True, verbose_name='Город', related_name='addresses')
#
#     def __str__(self):
#         return f'Доставка для {self.customer.user.first_name} на заказ №{self.order.pk}'
#
#     class Meta:
#         verbose_name = 'Адрес доставки'
#         verbose_name_plural = 'Адреса доставок'


class Region(models.Model):
    title = models.CharField(max_length=150, verbose_name='Регион')

    def __str__(self):
        return self.title

    class Meta:
        verbose_name = 'Регион'
        verbose_name_plural = 'Регионы'


class City(models.Model):
    title = models.CharField(max_length=150, verbose_name='Город')
    region = models.ForeignKey(
        Region, on_delete=models.CASCADE, verbose_name='Регион', related_name='cities'
    )

    def __str__(self):
        return self.title

    class Meta:
        verbose_name = 'Город'
        verbose_name_plural = 'Города'


# =============== ORDER TRACKING =================


class OrderTracking(models.Model):
    invoice_no = models.IntegerField(default=0, unique=True ,verbose_name='Invoice № of order')
    order_code = models.CharField(default='No order code', unique=True, max_length=10, verbose_name='Code of order')

    sender_name = models.CharField(max_length=255, verbose_name=_("Sender Name"))
    sender_tel = models.CharField(max_length=20, verbose_name=_("Sender Telephone"))

    receiver = models.ForeignKey(Receiver, on_delete=models.CASCADE, related_name="orders_track", verbose_name=_("Receiver"))

    passport = models.CharField(max_length=20, verbose_name=_("Passport Number"))
    birth_date = models.DateField(verbose_name=_("Birth Date"))
    address = models.TextField(verbose_name=_("Address"))
    product_details = models.TextField(verbose_name=_("Product Details"))
    brutto = models.DecimalField(max_digits=10, decimal_places=2, verbose_name=_("Brutto Weight"))
    total_value = models.DecimalField(max_digits=10, decimal_places=2, verbose_name=_("Total Value"))
    created_at = models.DateTimeField(auto_now_add=True, verbose_name=_("Created At"))
    updated_at = models.DateTimeField(auto_now=True, verbose_name=_("Updated At"))

    def __str__(self):
        return f"Order for {self.receiver.receiver.username if self.receiver.receiver else 'Unknown'}"

    class Meta:
        verbose_name = _("Order Tracking")
        verbose_name_plural = _("Order Trackings")
        ordering = ["-created_at"]











