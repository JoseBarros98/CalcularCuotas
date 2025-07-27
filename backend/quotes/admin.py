from django.contrib import admin
from .models import ShippingRoute, BaseRate, Quote, QuoteItem

@admin.register(ShippingRoute)
class ShippingRouteAdmin(admin.ModelAdmin):
    list_display = ('origin_port', 'destination_port', 'estimated_transit_days', 'is_active')
    list_filter = ('is_active', 'origin_port__country', 'destination_port__country')
    search_fields = ('origin_port__name', 'destination_port__name', 'origin_port__code', 'destination_port__code')
    raw_id_fields = ('origin_port', 'destination_port')

@admin.register(BaseRate)
class BaseRateAdmin(admin.ModelAdmin):
    list_display = ('route', 'container_type', 'base_rate_usd', 'fuel_surcharge_percentage', 'effective_from', 'effective_to', 'is_active')
    list_filter = ('is_active', 'container_type', 'effective_from')
    search_fields = ('route__origin_port__name', 'route__destination_port__name', 'container_type__name')
    raw_id_fields = ('route', 'container_type')

class QuoteItemInline(admin.TabularInline):
    model = QuoteItem
    extra = 1
    raw_id_fields = ('container_type', 'cargo_type')

@admin.register(Quote)
class QuoteAdmin(admin.ModelAdmin):
    list_display = ('quote_number', 'customer_name', 'customer_email', 'origin_port', 'destination_port', 'total_amount', 'status', 'valid_until', 'created_at', 'created_by')
    list_filter = ('status', 'origin_port__country', 'destination_port__country', 'created_at', 'created_by')
    search_fields = ('quote_number', 'customer_name', 'customer_email', 'origin_port__name', 'destination_port__name')
    date_hierarchy = 'created_at'
    inlines = [QuoteItemInline]
    raw_id_fields = ('origin_port', 'destination_port', 'created_by')
    readonly_fields = ('quote_number', 'total_amount', 'created_at', 'updated_at')