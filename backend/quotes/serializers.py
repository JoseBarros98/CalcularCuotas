from rest_framework import serializers
from .models import ShippingRoute, BaseRate, Quote, QuoteItem, Port
from ports.serializers import PortSerializer
from containers.serializers import ContainerTypeSerializer, CargoTypeSerializer
from containers.models import ContainerType, CargoType  

class ShippingRouteSerializer(serializers.ModelSerializer):
    origin_port = PortSerializer(read_only=True)
    destination_port = PortSerializer(read_only=True)
    
    origin_port_id = serializers.PrimaryKeyRelatedField(
        queryset=Port.objects.all(), source='origin_port', write_only=True
    )
    destination_port_id = serializers.PrimaryKeyRelatedField(
        queryset=Port.objects.all(), source='destination_port', write_only=True
    )

    class Meta:
        model = ShippingRoute
        fields = '__all__'
        read_only_fields = ('distance_nautical_miles', 'estimated_transit_days')

class BaseRateSerializer(serializers.ModelSerializer):
    route = ShippingRouteSerializer(read_only=True)
    container_type = ContainerTypeSerializer(read_only=True)
    
    route_id = serializers.PrimaryKeyRelatedField(
        queryset=ShippingRoute.objects.all(), source='route', write_only=True
    )
    container_type_id = serializers.PrimaryKeyRelatedField(
        queryset=ContainerType.objects.all(), source='container_type', write_only=True
    )

    class Meta:
        model = BaseRate
        fields = '__all__'

class QuoteItemSerializer(serializers.ModelSerializer):
    container_type = ContainerTypeSerializer(read_only=True)
    cargo_type = CargoTypeSerializer(read_only=True)
    
    container_type_id = serializers.PrimaryKeyRelatedField(
        queryset=ContainerType.objects.all(), source='container_type', write_only=True
    )
    cargo_type_id = serializers.PrimaryKeyRelatedField(
        queryset=CargoType.objects.all(), source='cargo_type', write_only=True
    )

    class Meta:
        model = QuoteItem
        fields = '__all__'
        read_only_fields = ('subtotal',) # Subtotal se calcula automáticamente

class QuoteSerializer(serializers.ModelSerializer):
    items = QuoteItemSerializer(many=True, read_only=True)
    
    origin_port = PortSerializer(read_only=True)
    destination_port = PortSerializer(read_only=True)
    
    origin_port_id = serializers.PrimaryKeyRelatedField(
        queryset=Port.objects.all(), source='origin_port', write_only=True
    )
    destination_port_id = serializers.PrimaryKeyRelatedField(
        queryset=Port.objects.all(), source='destination_port', write_only=True
    )

    class Meta:
        model = Quote
        fields = '__all__'
        read_only_fields = ('quote_number', 'total_amount', 'created_at', 'updated_at', 'created_by')

    def create(self, validated_data):
        # Manejar la creación de QuoteItems si se envían en la misma solicitud
        items_data = self.context['request'].data.get('items', [])
        quote = Quote.objects.create(**validated_data)
        for item_data in items_data:
            # Asegúrate de que los IDs de container_type y cargo_type se manejen correctamente
            container_type_id = item_data.pop('container_type_id')
            cargo_type_id = item_data.pop('cargo_type_id')
            
            container_type = ContainerType.objects.get(id=container_type_id)
            cargo_type = CargoType.objects.get(id=cargo_type_id)
            
            QuoteItem.objects.create(
                quote=quote, 
                container_type=container_type, 
                cargo_type=cargo_type, 
                **item_data
            )
        return quote

    def update(self, instance, validated_data):
        
        return super().update(instance, validated_data)