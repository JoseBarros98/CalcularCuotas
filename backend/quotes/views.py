from django.shortcuts import render
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import ShippingRoute, BaseRate, Quote, QuoteItem, ContainerType, CargoType
from .serializers import ShippingRouteSerializer, BaseRateSerializer, QuoteSerializer, QuoteItemSerializer, PortSerializer, ContainerTypeSerializer, CargoTypeSerializer
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
from django.db.models import Q
from datetime import date, timedelta

class ShippingRouteViewSet(viewsets.ModelViewSet):
    queryset = ShippingRoute.objects.all()
    serializer_class = ShippingRouteSerializer
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['origin_port', 'destination_port', 'is_active']
    search_fields = ['origin_port__name', 'destination_port__name', 'origin_port__code', 'destination_port__code']
    ordering_fields = ['origin_port__name', 'destination_port__name', 'estimated_transit_days']

class BaseRateViewSet(viewsets.ModelViewSet):
    queryset = BaseRate.objects.all()
    serializer_class = BaseRateSerializer
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['route', 'container_type', 'is_active', 'effective_from', 'effective_to']
    search_fields = ['route__origin_port__name', 'route__destination_port__name', 'container_type__name']
    ordering_fields = ['effective_from', 'base_rate_usd']

class QuoteViewSet(viewsets.ModelViewSet):
    queryset = Quote.objects.all()
    serializer_class = QuoteSerializer
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['status', 'origin_port', 'destination_port', 'customer_email', 'created_by']
    search_fields = ['quote_number', 'customer_name', 'customer_email', 'origin_port__name', 'destination_port__name']
    ordering_fields = ['created_at', 'total_amount', 'valid_until']

    def perform_create(self, serializer):
        
        if self.request.user.is_authenticated:
            serializer.save(created_by=self.request.user)
        else:
            serializer.save()

    @action(detail=False, methods=['post'])
    def calculate_quote(self, request):
        """
        Calcula una cotización basada en los parámetros de entrada.
        """
        origin_port_id = request.data.get('origin_port_id')
        destination_port_id = request.data.get('destination_port_id')
        container_type_id = request.data.get('container_type_id')
        cargo_type_id = request.data.get('cargo_type_id')
        quantity = request.data.get('quantity', 1)
        weight_kg = request.data.get('weight_kg')
        volume_cbm = request.data.get('volume_cbm')

        if not all([origin_port_id, destination_port_id, container_type_id, cargo_type_id, weight_kg, volume_cbm]):
            return Response({"error": "Missing required parameters."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            from decimal import Decimal
            # 1. Encontrar la ruta
            route = ShippingRoute.objects.get(
                origin_port_id=origin_port_id,
                destination_port_id=destination_port_id,
                is_active=True
            )

            # 2. Encontrar la tarifa base activa para la ruta y tipo de contenedor
            today = date.today()
            base_rate_obj = BaseRate.objects.filter(
                route=route,
                container_type_id=container_type_id,
                effective_from__lte=today,
                is_active=True,
            ).filter(
                Q(effective_to__gte=today) | Q(effective_to__isnull=True)
            ).first()

            if not base_rate_obj:
                return Response({"error": "No active base rate found for this route and container type."}, 
                                status=status.HTTP_404_NOT_FOUND)

            # 3. Obtener tipo de contenedor y carga
            container_type = ContainerType.objects.get(id=container_type_id)
            cargo_type = CargoType.objects.get(id=cargo_type_id)

            # 4. Calcular el costo total usando Decimal
            base_cost = Decimal(str(base_rate_obj.base_rate_usd))
            fuel_surcharge_percentage = Decimal(str(base_rate_obj.fuel_surcharge_percentage))
            quantity_dec = Decimal(str(quantity))
            handling_fee = Decimal('50.00')
            documentation_fee = Decimal('25.00')

            fuel_surcharge_amount = base_cost * (fuel_surcharge_percentage / Decimal('100'))
            insurance_fee = (base_cost + fuel_surcharge_amount) * Decimal('0.01')

            total_item_cost = (base_cost + fuel_surcharge_amount + handling_fee + insurance_fee) * quantity_dec
            total_quote_amount = total_item_cost + documentation_fee

            # Preparar la respuesta
            calculated_quote = {
                "origin_port": PortSerializer(route.origin_port).data,
                "destination_port": PortSerializer(route.destination_port).data,
                "container_type": ContainerTypeSerializer(container_type).data,
                "cargo_type": CargoTypeSerializer(cargo_type).data,
                "quantity": quantity,
                "weight_kg": weight_kg,
                "volume_cbm": volume_cbm,
                "estimated_transit_days": route.estimated_transit_days,
                "breakdown": {
                    "base_rate_per_container": float(base_cost),
                    "fuel_surcharge_percentage": float(fuel_surcharge_percentage),
                    "fuel_surcharge_amount_per_container": float(fuel_surcharge_amount),
                    "handling_fee_per_container": float(handling_fee),
                    "insurance_fee_per_container": float(insurance_fee),
                    "documentation_fee_per_quote": float(documentation_fee),
                },
                "total_item_cost": float(total_item_cost),
                "total_quote_amount": float(total_quote_amount),
                "currency": "USD",
                "valid_until": (today + timedelta(days=7)).isoformat()
            }

            return Response(calculated_quote, status=status.HTTP_200_OK)

        except ShippingRoute.DoesNotExist:
            return Response({"error": "Shipping route not found or inactive."}, status=status.HTTP_404_NOT_FOUND)
        except ContainerType.DoesNotExist:
            return Response({"error": "Container type not found."}, status=status.HTTP_404_NOT_FOUND)
        except CargoType.DoesNotExist:
            return Response({"error": "Cargo type not found."}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class QuoteItemViewSet(viewsets.ModelViewSet):
    queryset = QuoteItem.objects.all()
    serializer_class = QuoteItemSerializer
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['quote', 'container_type', 'cargo_type']
    ordering_fields = ['id']