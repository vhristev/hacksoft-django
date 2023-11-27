from django.contrib import admin
from django.urls import include, path  # Make sure to include 'include' here

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", include("service.urls")),  # Now 'include' should be recognized
    # ... any other path configurations ...
]
