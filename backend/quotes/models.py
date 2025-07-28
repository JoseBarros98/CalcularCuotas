from django.db import models
from decimal import Decimal
from django.contrib.auth.models import User
from ports.models import Port
from containers.models import ContainerType, CargoType

class ShippingRoute(models.Model):
    origin_port = models.ForeignKey(Port, on_delete=models.CASCADE, related_name='routes_from')
    destination_port = models.ForeignKey(Port, on_delete=models.CASCADE, related_name='routes_to')
    distance_nautical_miles = models.IntegerField()
    estimated_transit_days = models.IntegerField()
    is_active = models.BooleanField(default=True)
    
    class Meta:
        unique_together = ['origin_port', 'destination_port']
        ordering = ['origin_port', 'destination_port']
    
    def __str__(self):
        return f"{self.origin_port.code} → {self.destination_port.code}"

class BaseRate(models.Model):
    route = models.ForeignKey(ShippingRoute, on_delete=models.CASCADE, related_name='base_rates')
    container_type = models.ForeignKey(ContainerType, on_delete=models.CASCADE)
    base_rate_usd = models.DecimalField(max_digits=10, decimal_places=2)
    fuel_surcharge_percentage = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    currency_adjustment_factor = models.DecimalField(max_digits=5, decimal_places=4, default=Decimal('1.0'))
    effective_from = models.DateField()
    effective_to = models.DateField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        ordering = ['-effective_from']
    
    def __str__(self):
        return f"{self.route} - {self.container_type} - ${self.base_rate_usd}"

class Quote(models.Model):
    STATUS_CHOICES = [
        ('DRAFT', 'Draft'),
        ('SENT', 'Sent'),
        ('ACCEPTED', 'Accepted'),
        ('REJECTED', 'Rejected'),
        ('EXPIRED', 'Expired'),
    ]
    
    quote_number = models.CharField(max_length=20, unique=True)
    customer_name = models.CharField(max_length=200)
    customer_email = models.EmailField()
    customer_company = models.CharField(max_length=200, blank=True)
    
    origin_port = models.ForeignKey(Port, on_delete=models.CASCADE, related_name='quotes_from')
    destination_port = models.ForeignKey(Port, on_delete=models.CASCADE, related_name='quotes_to')
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='DRAFT')
    
    total_amount = models.DecimalField(max_digits=12, decimal_places=2)
    currency = models.CharField(max_length=3, default='USD')
    
    valid_until = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    
    notes = models.TextField(blank=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Quote {self.quote_number} - {self.customer_name}"
    
    def save(self, *args, **kwargs):
        if not self.quote_number:
            # Generate quote number
            import datetime
            today = datetime.date.today()
            count = Quote.objects.filter(created_at__date=today).count() + 1
            self.quote_number = f"SQ{today.strftime('%Y%m%d')}{count:04d}"
        super().save(*args, **kwargs)

class QuoteItem(models.Model):
    quote = models.ForeignKey(Quote, on_delete=models.CASCADE, related_name='items')
    container_type = models.ForeignKey(ContainerType, on_delete=models.CASCADE)
    cargo_type = models.ForeignKey(CargoType, on_delete=models.CASCADE)
    quantity = models.IntegerField(default=1)
    weight_kg = models.DecimalField(max_digits=10, decimal_places=2)
    volume_cbm = models.DecimalField(max_digits=10, decimal_places=2)
    
    base_rate = models.DecimalField(max_digits=10, decimal_places=2)
    fuel_surcharge = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    handling_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    documentation_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    insurance_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    subtotal = models.DecimalField(max_digits=10, decimal_places=2)
    
    class Meta:
        ordering = ['id']
    
    def __str__(self):
        return f"{self.quote.quote_number} - {self.container_type} x{self.quantity}"
    
    def save(self, *args, **kwargs):
        from decimal import Decimal
        # Convertir todos los valores a Decimal por si acaso
        base_rate = Decimal(str(self.base_rate))
        fuel_surcharge = Decimal(str(self.fuel_surcharge))
        handling_fee = Decimal(str(self.handling_fee))
        documentation_fee = Decimal(str(self.documentation_fee))
        insurance_fee = Decimal(str(self.insurance_fee))
        quantity = Decimal(str(self.quantity))
        self.subtotal = (
            (base_rate + fuel_surcharge + handling_fee + documentation_fee + insurance_fee) * quantity
        )
        super().save(*args, **kwargs)