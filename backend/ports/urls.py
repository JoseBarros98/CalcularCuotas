from rest_framework.routers import DefaultRouter
from .views import CountryViewSet, PortViewSet

router = DefaultRouter()
router.register(r'countries', CountryViewSet)
router.register(r'ports', PortViewSet)

urlpatterns = router.urls