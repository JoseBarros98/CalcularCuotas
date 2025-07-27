from django.shortcuts import render
from rest_framework import viewsets
from .models import Country, Port
from .serializers import CountrySerializer, PortSerializer
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter

class CountryViewSet(viewsets.ModelViewSet):
    queryset = Country.objects.all()
    serializer_class = CountrySerializer
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['name', 'code', 'continent']
    ordering_fields = ['name', 'code']

class PortViewSet(viewsets.ModelViewSet):
    queryset = Port.objects.all()
    serializer_class = PortSerializer
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['country', 'is_active']
    search_fields = ['name', 'code', 'city', 'country__name']
    ordering_fields = ['name', 'code', 'city', 'country__name']

