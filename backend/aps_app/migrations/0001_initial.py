# Generated by Django 5.1.7 on 2025-04-01 09:09

import django.core.validators
import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Brand',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=150, verbose_name='Модель товара')),
                ('created_at', models.DateTimeField(auto_now_add=True, verbose_name='Дата добавления')),
            ],
            options={
                'verbose_name': 'Бренд',
                'verbose_name_plural': 'Бренды',
                'ordering': ['-created_at'],
            },
        ),
        migrations.CreateModel(
            name='City',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=150, verbose_name='Город')),
            ],
            options={
                'verbose_name': 'Город',
                'verbose_name_plural': 'Города',
            },
        ),
        migrations.CreateModel(
            name='OrderMoneyLimit',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('limit', models.FloatField(default=0, verbose_name='Лимит на $1000')),
                ('created_at', models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')),
            ],
            options={
                'verbose_name': 'Лимит на заказ',
                'verbose_name_plural': 'Лимиты на заказы',
            },
        ),
        migrations.CreateModel(
            name='Region',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=150, verbose_name='Регион')),
            ],
            options={
                'verbose_name': 'Регион',
                'verbose_name_plural': 'Регионы',
            },
        ),
        migrations.CreateModel(
            name='Branch',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('phone', models.CharField(blank=True, max_length=20, null=True, verbose_name='Телефон')),
                ('seller', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL, verbose_name='Seller')),
            ],
            options={
                'verbose_name': 'Филиал',
                'verbose_name_plural': 'Филиалы',
                'ordering': ['seller'],
            },
        ),
        migrations.CreateModel(
            name='Category',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=100, verbose_name='Название категории')),
                ('slug', models.SlugField(blank=True, null=True, unique=True, verbose_name='Слаг категории')),
                ('parent', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='subcategories', to='aps_app.category', verbose_name='Категория')),
            ],
            options={
                'verbose_name': 'Категория',
                'verbose_name_plural': 'Категории',
                'ordering': ['title'],
            },
        ),
        migrations.CreateModel(
            name='OrderAdmin',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('street', models.TextField(validators=[django.core.validators.MaxLengthValidator(150)], verbose_name='Улица')),
                ('weight', models.FloatField(default=0, verbose_name='Вес заказа')),
                ('full_price', models.FloatField(verbose_name='Общая сумма')),
                ('passport_id', models.CharField(max_length=10, verbose_name='Серия паспорта')),
                ('dof', models.CharField(max_length=20, verbose_name='Дата рождение')),
                ('notes', models.TextField(validators=[django.core.validators.MaxLengthValidator(200)], verbose_name='Заметки')),
                ('created_at', models.DateTimeField(auto_now_add=True, verbose_name='Дата заказа')),
                ('city', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to='aps_app.city', verbose_name='Город')),
                ('limit', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='aps_app.ordermoneylimit', verbose_name='Лимит')),
            ],
            options={
                'verbose_name': 'Заказ',
                'verbose_name_plural': 'Заказы',
            },
        ),
        migrations.CreateModel(
            name='Product',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=200, verbose_name='Название товара')),
                ('description', models.TextField(validators=[django.core.validators.MinLengthValidator(100), django.core.validators.MaxLengthValidator(500)], verbose_name='Описание товара')),
                ('short_description', models.TextField(default='Описание отсутствует.', validators=[django.core.validators.MinLengthValidator(10), django.core.validators.MaxLengthValidator(100)], verbose_name='Краткое описание')),
                ('price', models.FloatField(verbose_name='Цена товара')),
                ('quantity', models.PositiveIntegerField(default=0, verbose_name='Количество')),
                ('size', models.CharField(blank=True, max_length=10, null=True, verbose_name='Размер')),
                ('slug', models.SlugField(blank=True, null=True, unique=True, verbose_name='Слаг товара')),
                ('discount', models.PositiveIntegerField(blank=True, null=True, verbose_name='Скидка')),
                ('created_at', models.DateTimeField(auto_now_add=True, verbose_name='Дата добавление')),
                ('updated_at', models.DateTimeField(auto_now=True, verbose_name='Дата Изменение')),
                ('category', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='aps_app.category', verbose_name='Категория товара')),
                ('model', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to='aps_app.brand', verbose_name='Модель')),
            ],
            options={
                'verbose_name': 'Товар',
                'verbose_name_plural': 'Товары',
                'ordering': ['-created_at'],
            },
        ),
        migrations.CreateModel(
            name='OrderProduct',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('quantity', models.IntegerField(default=0, verbose_name='В количестве')),
                ('added_at', models.DateTimeField(auto_now_add=True, verbose_name='Дата добавления')),
                ('updated_at', models.DateTimeField(auto_now=True, verbose_name='Дата изменения')),
                ('order', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='order_products', to='aps_app.orderadmin', verbose_name='Заказ')),
                ('product', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='order_products', to='aps_app.product', verbose_name='Товар')),
            ],
            options={
                'verbose_name': 'Заказанный товар',
                'verbose_name_plural': 'Заказанные товары',
            },
        ),
        migrations.CreateModel(
            name='ImageProduct',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('image', models.ImageField(upload_to='images/', verbose_name='Фото товара')),
                ('product', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='images', to='aps_app.product', verbose_name='Товар')),
            ],
            options={
                'verbose_name': 'Изображение товара',
                'verbose_name_plural': 'Изображения товаров',
                'ordering': ['id'],
            },
        ),
        migrations.CreateModel(
            name='Receiver',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('phone', models.CharField(blank=True, max_length=20, null=True, verbose_name='Телефон')),
                ('passport_id', models.CharField(blank=True, max_length=20, null=True, verbose_name='Паспорт ID')),
                ('receiver', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL, verbose_name='User')),
            ],
            options={
                'verbose_name': 'Получатель',
                'verbose_name_plural': 'Получатели',
                'ordering': ['receiver'],
            },
        ),
        migrations.CreateModel(
            name='OrderTracking',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('sender_name', models.CharField(max_length=255, verbose_name='Sender Name')),
                ('sender_tel', models.CharField(max_length=20, verbose_name='Sender Telephone')),
                ('passport', models.CharField(max_length=20, unique=True, verbose_name='Passport Number')),
                ('birth_date', models.TextField(verbose_name='Birth Date')),
                ('address', models.TextField(verbose_name='Address')),
                ('product_details', models.TextField(verbose_name='Product Details')),
                ('brutto', models.DecimalField(decimal_places=2, max_digits=10, verbose_name='Brutto Weight')),
                ('total_value', models.DecimalField(decimal_places=2, max_digits=10, verbose_name='Total Value')),
                ('created_at', models.DateTimeField(auto_now_add=True, verbose_name='Created At')),
                ('updated_at', models.DateTimeField(auto_now=True, verbose_name='Updated At')),
                ('receiver', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='orders_track', to='aps_app.receiver', verbose_name='Receiver')),
            ],
            options={
                'verbose_name': 'Order Tracking',
                'verbose_name_plural': 'Order Trackings',
                'ordering': ['-created_at'],
            },
        ),
        migrations.AddField(
            model_name='ordermoneylimit',
            name='customer',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='money_limits', to='aps_app.receiver', verbose_name='Покупатель'),
        ),
        migrations.AddField(
            model_name='orderadmin',
            name='customer',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='orders', to='aps_app.receiver', verbose_name='Покупатель'),
        ),
        migrations.AddField(
            model_name='orderadmin',
            name='region',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to='aps_app.region', verbose_name='Регион'),
        ),
        migrations.AddField(
            model_name='city',
            name='region',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='cities', to='aps_app.region', verbose_name='Регион'),
        ),
        migrations.CreateModel(
            name='UserDevice',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('fcm_token', models.CharField(max_length=255, unique=True)),
                ('user', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'Устройство пользователя',
                'verbose_name_plural': 'Устройство пользователей',
            },
        ),
    ]
