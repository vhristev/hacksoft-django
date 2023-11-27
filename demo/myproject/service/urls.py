from django.urls import path

from . import views

urlpatterns = [
    # path("clock/", views.clock, name="clock"),
    path("", views.clock, name="clock"),
    path("random_number/", views.random_number, name="random_number"),
    path("service_status/", views.service_status, name="service_status"),
]
