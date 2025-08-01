# Generated by Django 5.2.4 on 2025-07-27 20:12

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('containers', '0001_initial'),
        ('ports', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Quote',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('quote_number', models.CharField(max_length=20, unique=True)),
                ('customer_name', models.CharField(max_length=200)),
                ('customer_email', models.EmailField(max_length=254)),
                ('customer_company', models.CharField(blank=True, max_length=200)),
                ('status', models.CharField(choices=[('DRAFT', 'Draft'), ('SENT', 'Sent'), ('ACCEPTED', 'Accepted'), ('REJECTED', 'Rejected'), ('EXPIRED', 'Expired')], default='DRAFT', max_length=20)),
                ('total_amount', models.DecimalField(decimal_places=2, max_digits=12)),
                ('currency', models.CharField(default='USD', max_length=3)),
                ('valid_until', models.DateTimeField()),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('notes', models.TextField(blank=True)),
                ('created_by', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
                ('destination_port', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='quotes_to', to='ports.port')),
                ('origin_port', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='quotes_from', to='ports.port')),
            ],
            options={
                'ordering': ['-created_at'],
            },
        ),
        migrations.CreateModel(
            name='QuoteItem',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('quantity', models.IntegerField(default=1)),
                ('weight_kg', models.DecimalField(decimal_places=2, max_digits=10)),
                ('volume_cbm', models.DecimalField(decimal_places=2, max_digits=10)),
                ('base_rate', models.DecimalField(decimal_places=2, max_digits=10)),
                ('fuel_surcharge', models.DecimalField(decimal_places=2, default=0, max_digits=10)),
                ('handling_fee', models.DecimalField(decimal_places=2, default=0, max_digits=10)),
                ('documentation_fee', models.DecimalField(decimal_places=2, default=0, max_digits=10)),
                ('insurance_fee', models.DecimalField(decimal_places=2, default=0, max_digits=10)),
                ('subtotal', models.DecimalField(decimal_places=2, max_digits=10)),
                ('cargo_type', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='containers.cargotype')),
                ('container_type', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='containers.containertype')),
                ('quote', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='items', to='quotes.quote')),
            ],
            options={
                'ordering': ['id'],
            },
        ),
        migrations.CreateModel(
            name='ShippingRoute',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('distance_nautical_miles', models.IntegerField()),
                ('estimated_transit_days', models.IntegerField()),
                ('is_active', models.BooleanField(default=True)),
                ('destination_port', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='routes_to', to='ports.port')),
                ('origin_port', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='routes_from', to='ports.port')),
            ],
            options={
                'ordering': ['origin_port', 'destination_port'],
                'unique_together': {('origin_port', 'destination_port')},
            },
        ),
        migrations.CreateModel(
            name='BaseRate',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('base_rate_usd', models.DecimalField(decimal_places=2, max_digits=10)),
                ('fuel_surcharge_percentage', models.DecimalField(decimal_places=2, default=0, max_digits=5)),
                ('currency_adjustment_factor', models.DecimalField(decimal_places=4, default=1.0, max_digits=5)),
                ('effective_from', models.DateField()),
                ('effective_to', models.DateField(blank=True, null=True)),
                ('is_active', models.BooleanField(default=True)),
                ('container_type', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='containers.containertype')),
                ('route', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='base_rates', to='quotes.shippingroute')),
            ],
            options={
                'ordering': ['-effective_from'],
            },
        ),
    ]
