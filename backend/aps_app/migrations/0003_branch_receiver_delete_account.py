# Generated by Django 5.1.7 on 2025-03-11 09:43

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('aps_app', '0002_alter_account_is_customer_alter_account_is_seller'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Branch',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('email', models.EmailField(blank=True, max_length=254, null=True, verbose_name='Email')),
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
            name='Receiver',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('email', models.EmailField(blank=True, max_length=254, null=True, verbose_name='Email')),
                ('phone', models.CharField(blank=True, max_length=20, null=True, verbose_name='Телефон')),
                ('receiver', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL, verbose_name='User')),
            ],
            options={
                'verbose_name': 'Получатель',
                'verbose_name_plural': 'Получатели',
                'ordering': ['receiver'],
            },
        ),
        migrations.DeleteModel(
            name='Account',
        ),
    ]
