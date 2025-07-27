from django.contrib import admin
from .models import Country, Port

@admin.register(Country)
class CountryAdmin(admin.ModelAdmin):
    list_display = ('name', 'code', 'continent')
    search_fields = ('name', 'code')

@admin.register(Port)
class PortAdmin(admin.ModelAdmin):
    list_display = ('name', 'code', 'country', 'city', 'is_active')
    list_filter = ('country', 'is_active')
    search_fields = ('name', 'code', 'city')
    raw_id_fields = ('country',)