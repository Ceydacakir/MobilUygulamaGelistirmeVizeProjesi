from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from .models import Person

class PersonAPITests(TestCase):
    """
    Vize Yönergesindeki CRUD Uç Noktalarını Test Eden Birim Testler
    """
    def setUp(self):
        self.client = APIClient()
        self.person = Person.objects.create(
            fullName="Ahmet Yılmaz",
            department="Yazılım Geliştirme",
            photoUrl="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400",
            birthPlace="Adana",
            birthDate="1994-04-12",
            email="ahmet.yilmaz@sirket.com",
            phone="+905550123456"
        )

    def test_list_persons(self):
        """GET /api/persons: Tüm kişileri listeleme testi"""
        response = self.client.get('/api/persons')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(response.data), 1)

    def test_get_person_detail(self):
        """GET /api/persons/{id}: Belirtilen ID'ye sahip kişinin detaylarını alma testi"""
        response = self.client.get(f'/api/persons/{self.person.id}')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['fullName'], "Ahmet Yılmaz")

    def test_create_person(self):
        """POST /api/persons: Yeni kişi kaydı oluşturma testi"""
        new_data = {
            "fullName": "Canan Dağdeviren",
            "department": "Fizik Mühendisliği",
            "photoUrl": "https://picsum.photos/200",
            "birthPlace": "İstanbul",
            "birthDate": "1985-05-04",
            "email": "canan@akademi.edu.tr",
            "phone": "+905551112233"
        }
        response = self.client.post('/api/persons', new_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['fullName'], "Canan Dağdeviren")

    def test_update_person(self):
        """PUT /api/persons/{id}: Kişi bilgilerini güncelleme testi"""
        updated_data = {
            "fullName": "Ahmet Yılmaz",
            "department": "Kıdemli Yazılım Mimarı", # Güncellenen departman
            "photoUrl": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400",
            "birthPlace": "Adana",
            "birthDate": "1994-04-12",
            "email": "ahmet.yilmaz.lead@sirket.com", # Güncellenen e-posta
            "phone": "+905550123499" # Güncellenen telefon
        }
        response = self.client.put(f'/api/persons/{self.person.id}', updated_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['department'], "Kıdemli Yazılım Mimarı")

    def test_delete_person(self):
        """DELETE /api/persons/{id}: Kişiyi kalıcı olarak silme testi"""
        response = self.client.delete(f'/api/persons/{self.person.id}')
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        # Veritabanında artık olmamalı
        self.assertFalse(Person.objects.filter(id=self.person.id).exists())
