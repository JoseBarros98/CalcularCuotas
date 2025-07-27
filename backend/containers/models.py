from django.db import models

# Create your models here.
from django.db import models

class ContainerType(models.Model):
    CONTAINER_SIZES = [
        ('20', '20 feet'),
        ('40', '40 feet'),
        ('40HC', '40 feet High Cube'),
        ('45', '45 feet'),
    ]
    
    CONTAINER_TYPES = [
        ('DRY', 'Dry Container'),
        ('REEFER', 'Refrigerated Container'),
        ('OPEN_TOP', 'Open Top Container'),
        ('FLAT_RACK', 'Flat Rack Container'),
        ('TANK', 'Tank Container'),
    ]
    
    name = models.CharField(max_length=100)
    size = models.CharField(max_length=10, choices=CONTAINER_SIZES)
    type = models.CharField(max_length=20, choices=CONTAINER_TYPES)
    max_weight = models.DecimalField(max_digits=10, decimal_places=2)  # in kg
    internal_length = models.DecimalField(max_digits=6, decimal_places=2)  # in meters
    internal_width = models.DecimalField(max_digits=6, decimal_places=2)
    internal_height = models.DecimalField(max_digits=6, decimal_places=2)
    volume = models.DecimalField(max_digits=10, decimal_places=2)  # in cubic meters
    is_active = models.BooleanField(default=True)
    
    class Meta:
        ordering = ['size', 'type']
    
    def __str__(self):
        return f"{self.size}' {self.get_type_display()}"

class CargoType(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    hazardous = models.BooleanField(default=False)
    requires_special_handling = models.BooleanField(default=False)
    density_factor = models.DecimalField(max_digits=5, decimal_places=2, default=1.0)
    
    class Meta:
        ordering = ['name']
    
    def __str__(self):
        return self.name