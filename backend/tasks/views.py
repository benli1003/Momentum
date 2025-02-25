from rest_framework import viewsets, permissions #CRUD functionality and authentication
from .models import Task #Task database
from .serializers import TaskSerializer #convert JSON data

class TaskViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows users to view, create, edit, and delete their tasks.
    """
    serializer_class = TaskSerializer
    permission_classes = [permissions.IsAuthenticated]  # Restricts access to logged-in users
    
    # Users can only view their own tasks
    def get_queryset(self):
        return Task.objects.filter(user=self.request.user)

    # Assign the logged-in user as the task owner when creating a new task
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
