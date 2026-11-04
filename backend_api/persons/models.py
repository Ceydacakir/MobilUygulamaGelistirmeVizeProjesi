from django.db import models

class Person(models.Model):
    """
    Kişi Modeli: PDF yönergesindeki şema ile 1-e-1 uyumludur.
    Şema Alanları:
      - id: Otomatik birincil anahtar (Primary Key)
      - fullName: Kişinin tam adı ve soyadı
      - department: Çalıştığı departman veya unvan
      - photoUrl: Profil fotoğrafı bağlantısı (ağ resmi)
      - birthPlace: Doğum yeri
      - birthDate: Doğum tarihi (YYYY-AA-GG formatında)
      - email: İletişim e-posta adresi
      - phone: İletişim telefon numarası
    """
    fullName = models.CharField(max_length=150, verbose_name="Ad Soyad")
    department = models.CharField(max_length=150, verbose_name="Departman")
    photoUrl = models.CharField(max_length=500, verbose_name="Fotoğraf URL", blank=True, default="https://picsum.photos/200")
    birthPlace = models.CharField(max_length=100, verbose_name="Doğum Yeri")
    birthDate = models.DateField(verbose_name="Doğum Tarihi")
    email = models.EmailField(max_length=254, verbose_name="E-posta")
    phone = models.CharField(max_length=30, verbose_name="Telefon")

    class Meta:
        ordering = ['id']
        verbose_name = "Kişi"
        verbose_name_plural = "Kişiler"

    def __str__(self):
        return f"{self.fullName} ({self.department})"
