from django.shortcuts import render
from rest_framework import viewsets
from .models import ContainerType, CargoType
from .serializers import ContainerTypeSerializer, CargoTypeSerializer
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter

class ContainerTypeViewSet(viewsets.ModelViewSet):
    queryset = ContainerType.objects.all()
    serializer_class = ContainerTypeSerializer
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['size', 'type', 'is_active']
    search_fields = ['name', 'size', 'type']
    ordering_fields = ['size', 'type', 'max_weight']

class CargoTypeViewSet(viewsets.ModelViewSet):
    queryset = CargoType.objects.all()
    serializer_class = CargoTypeSerializer
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['name', 'description']
    ordering_fields = ['name', 'hazardous']
