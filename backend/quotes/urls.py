from rest_framework.routers import DefaultRouter
from django.urls import path
from .views import ShippingRouteViewSet, BaseRateViewSet, QuoteViewSet, QuoteItemViewSet

router = DefaultRouter()
router.register(r'shipping-routes', ShippingRouteViewSet)
router.register(r'base-rates', BaseRateViewSet)
router.register(r'quotes', QuoteViewSet)
router.register(r'quote-items', QuoteItemViewSet)

urlpatterns = [
    path('calculate_quote/', QuoteViewSet.as_view({'post': 'calculate_quote'}), name='calculate_quote'),
]
urlpatterns += router.urls