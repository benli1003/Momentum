from django.db import models
from django.contrib.auth.models import User

class Task(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)    #user
    title = models.CharField(max_length=255)                    #title
    is_completed = models.BooleanField(default=False)           #when the task is completed
    created_at = models.DateTimeField(auto_now_add=True)        #when the task is created
    updated_at = models.DateTimeField(auto_now=True)            #when the task is updated


    def __str__(self):
        return self.title
