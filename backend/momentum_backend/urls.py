from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from tasks.views import TaskViewSet


# Define the router
router = DefaultRouter()
router.register(r'tasks', TaskViewSet, basename='task')  # Register TaskViewSet

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),  # Include the registered routes
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),  # Login Token
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),  # Refresh Token
]
