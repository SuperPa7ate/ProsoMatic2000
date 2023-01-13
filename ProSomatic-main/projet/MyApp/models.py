from django.db import models

# Create your models here.

class Recording(models.Model):
    dateCreation = models.DateTimeField(auto_now_add=True, auto_now=False)
    auteur = models.CharField(default='anonymous', max_length=100)
    audio = models.TextField(default='')
