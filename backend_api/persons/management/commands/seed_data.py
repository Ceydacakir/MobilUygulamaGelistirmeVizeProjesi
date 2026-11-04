from django.core.management.base import BaseCommand
from persons.models import Person

class Command(BaseCommand):
    help = 'PDF yönergesindeki örnek kişi verilerini veritabanına ekler.'

    def handle(self, *args, **kwargs):
        initial_persons = [
            {
                "fullName": "Ahmet Yılmaz",
                "department": "Yazılım Geliştirme",
                "photoUrl": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80",
                "birthPlace": "Adana",
                "birthDate": "1994-04-12",
                "email": "ahmet.yilmaz@sirket.com",
                "phone": "+905550123456"
            },
            {
                "fullName": "Ayşe Kaya",
                "department": "İnsan Kaynakları",
                "photoUrl": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80",
                "birthPlace": "Ankara",
                "birthDate": "1996-08-20",
                "email": "ayse.kaya@sirket.com",
                "phone": "+905559876543"
            },
            {
                "fullName": "Mehmet Demir",
                "department": "Bilgi Teknolojileri",
                "photoUrl": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80",
                "birthPlace": "İstanbul",
                "birthDate": "1992-11-05",
                "email": "mehmet.demir@sirket.com",
                "phone": "+905554443322"
            }
        ]

        created_count = 0
        for data in initial_persons:
            obj, created = Person.objects.get_or_create(
                fullName=data["fullName"],
                defaults=data
            )
            if created:
                created_count += 1

        self.stdout.write(self.style.SUCCESS(f"{created_count} adet örnek kişi veritabanına başarıyla eklendi!"))
