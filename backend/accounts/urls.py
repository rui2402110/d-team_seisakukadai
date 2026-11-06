from django.urls import path
from accounts.views.loginView import *
from accounts.views.registerView import registerView
urlpatterns = [
    path("register/", registerView, name="register"),
]
