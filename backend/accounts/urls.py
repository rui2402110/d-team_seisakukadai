from django.urls import path
from accounts.views.loginView import loginView
from accounts.views.registerView import registerView

urlpatterns = [
    path("register/", registerView, name="register"),
    path("login/", loginView, name="login"),
]
