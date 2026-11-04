from django.contrib import admin
from .models import Person

@admin.register(Person)
class PersonAdmin(admin.ModelAdmin):
    list_display = ('id', 'fullName', 'department', 'email', 'phone')
    search_fields = ('fullName', 'department', 'email')
