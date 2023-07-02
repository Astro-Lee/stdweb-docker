"""
URL configuration for stdweb project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
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
from django.urls import path, re_path, include

from django.contrib.auth import views as auth_views

from . import settings
from . import views
from . import views_tasks

urlpatterns = [
    # path('', views.index, name='index'),
    path('', views.upload_file, name='index'),

    path('files/', views.list_files, {'path': ''}, name='files'),
    path('files/<path:path>', views.list_files, name='files'),
    path('view/<path:path>', views.download, {'attachment':False}, name='view'),
    path('download/<path:path>', views.download, {'attachment':True}, name='download'),

    path('preview/<path:path>', views.preview, name='preview'),

    # Uploads
    path('upload/', views.upload_file, name='upload'),
    path('reuse/', views.reuse_file, name='reuse'),

    # Tasks
    path('tasks/', views_tasks.tasks, {'id':None}, name='tasks'),
    path('tasks/<int:id>', views_tasks.tasks, name='tasks'),

    path('tasks/<int:id>/files/', views_tasks.tasks_files, {'path': ''}, name='tasks_files'),
    path('tasks/<int:id>/files/<path:path>', views_tasks.tasks_files, name='tasks_files'),

    # Auth
    path('login/', auth_views.LoginView.as_view(), name='login'),
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),

    # Admin panel
    path('admin/', admin.site.urls),
]
