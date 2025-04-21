from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('register/', views.register, name='register'),
    path('login/', views.login, name='login'),
    path('logout/', views.logout, name='logout'),
    path('process-command/', views.process_command, name='process_command'),
    path('create-task/', views.create_task, name='create_task'),
    path('delete-task/<int:task_id>/', views.delete_task, name='delete_task'),
    path('mark-task/<int:task_id>/', views.mark_task_complete, name='mark_task_complete'),
    path('update-task/<int:task_id>/', views.update_task, name='update_task'),
    path('list-task/', views.list_task, name='list_task'),
    path('save-location/', views.save_user_location, name='save_user_location'),
]