from django.contrib import admin
from .models import ContainerType, CargoType

@admin.register(ContainerType)
class ContainerTypeAdmin(admin.ModelAdmin):
    list_display = ('name', 'size', 'type', 'max_weight', 'is_active')
    list_filter = ('size', 'type', 'is_active')
    search_fields = ('name', 'size', 'type')

@admin.register(CargoType)
class CargoTypeAdmin(admin.ModelAdmin):
    list_display = ('name', 'hazardous', 'requires_special_handling')
    search_fields = ('name',)