"""TALAO URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from MyApp import views as MyApp
urlpatterns = [
    path('admin/', admin.site.urls),
    path('', MyApp.home), # Chemin d'accès à la page principale
    path('contact/', MyApp.contact), # Chemin d'accès à la page de contact
    path('aide/', MyApp.aide), # Chemin d'accès à la d'aide
    path('commencer/', MyApp.commencer), # Chemin d'accès à la page commencer
    path('test1/', MyApp.test1), # Chemin d'accès à la page commencer
]
