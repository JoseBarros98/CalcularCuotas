from rest_framework.routers import DefaultRouter
from .views import ContainerTypeViewSet, CargoTypeViewSet

router = DefaultRouter()
router.register(r'container-types', ContainerTypeViewSet)
router.register(r'cargo-types', CargoTypeViewSet)

urlpatterns = router.urls