from rest_framework import generics
from .models import Person
from .serializers import PersonSerializer

class PersonListCreateView(generics.ListCreateAPIView):
    """
    GET /api/persons      -> Tüm kişileri dizi (array) formatında listeler.
    POST /api/persons     -> Yeni kişi kaydı oluşturur (Gelen JSON gövdesini kaydeder).
    """
    queryset = Person.objects.all()
    serializer_class = PersonSerializer

class PersonDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    GET /api/persons/{id}    -> Belirtilen ID'ye sahip kişinin tüm detaylarını döner.
    PUT /api/persons/{id}    -> Kişinin iletişim ve unvan bilgilerini günceller.
    DELETE /api/persons/{id} -> İlgili kaydı veritabanından kalıcı olarak siler.
    """
    queryset = Person.objects.all()
    serializer_class = PersonSerializer
