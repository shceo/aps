from django.db import models
from django.contrib.auth.models import User
from django.urls import reverse


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

from django.urls import reverse


class Category(models.Model):
    title = models.CharField(max_length=100, verbose_name='Название категории')
    slug = models.SlugField(unique=True, blank=True, null=True, verbose_name='Слаг категории')
    parent = models.ForeignKey(
        'self', on_delete=models.SET_NULL, null=True, blank=True,
        related_name='subcategories', verbose_name='Категория'
    )

    def get_absolute_url(self):
        return reverse('category', kwargs={'slug': self.slug})

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
    description = models.TextField(verbose_name='Описание товара')
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


class Order(models.Model):
    customer = models.ForeignKey(
        Receiver, on_delete=models.SET_NULL, null=True, verbose_name='Покупатель', related_name='orders'
    )
    weight = models.FloatField(default=0, verbose_name='Вес заказа')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата заказа')
    is_completed = models.BooleanField(default=False, verbose_name='Статус заказа')
    payment = models.BooleanField(default=False, verbose_name='Статус оплаты')
    shipping = models.BooleanField(default=True, verbose_name='Доставка')

    def __str__(self):
        return f'Номер заказа: {self.pk}, на имя: {self.customer.user.username}'

    class Meta:
        verbose_name = 'Заказ'
        verbose_name_plural = 'Заказы'

    @property
    def get_order_total_price(self):
        return sum(item.get_total_price for item in self.orderproduct_set.all())

    @property
    def get_order_total_quantity(self):
        return sum(item.quantity for item in self.orderproduct_set.all())


class OrderProduct(models.Model):
    product = models.ForeignKey(
        Product, on_delete=models.SET_NULL, null=True, verbose_name='Товар', related_name='order_products'
    )
    order = models.ForeignKey(
        Order, on_delete=models.SET_NULL, null=True, verbose_name='Заказ', related_name='order_products'
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


class ShippingAddress(models.Model):
    customer = models.ForeignKey(
        Receiver, on_delete=models.SET_NULL, null=True, verbose_name='Покупатель', related_name='shipping_addresses'
    )
    order = models.ForeignKey(
        Order, on_delete=models.SET_NULL, null=True, verbose_name='Заказ', related_name='shipping_addresses'
    )
    address = models.CharField(max_length=150, verbose_name='Адрес доставки (улица, дом, кв)')
    phone = models.CharField(max_length=30, verbose_name='Номер телефона')
    comment = models.TextField(verbose_name='Комментарий к заказу', max_length=200)
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата оформления доставки')
    region = models.ForeignKey('Region', on_delete=models.SET_NULL, null=True, verbose_name='Регион', related_name='addresses')
    city = models.ForeignKey('City', on_delete=models.SET_NULL, null=True, verbose_name='Город', related_name='addresses')

    def __str__(self):
        return f'Доставка для {self.customer.user.first_name} на заказ №{self.order.pk}'

    class Meta:
        verbose_name = 'Адрес доставки'
        verbose_name_plural = 'Адреса доставок'


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













