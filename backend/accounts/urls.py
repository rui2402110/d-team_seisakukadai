from django.urls import path
from accounts.views.loginView import loginView
from accounts.views.registerView import registerView
from accounts.views.followView import followView

urlpatterns = [
    path("register/", registerView, name="register"),
    path("login/", loginView, name="login"),
    path('users/<str:user_id>/follow/', followView, name='follow'),
]
