from rest_framework.routers import DefaultRouter
from .views import ShippingRouteViewSet, BaseRateViewSet, QuoteViewSet, QuoteItemViewSet

router = DefaultRouter()
router.register(r'shipping-routes', ShippingRouteViewSet)
router.register(r'base-rates', BaseRateViewSet)
router.register(r'quotes', QuoteViewSet)
router.register(r'quote-items', QuoteItemViewSet)

urlpatterns = router.urls