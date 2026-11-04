from rest_framework import serializers
from .models import Person

class PersonSerializer(serializers.ModelSerializer):
    """
    Person nesnelerini JSON formatına dönüştüren (ve tersine JSON'dan model oluşturan) serializer sınıfı.
    PDF belgesindeki payload ile tamamen örtüşür:
    {
      "id": 104,
      "fullName": "Ahmet Yılmaz",
      "department": "Yazılım Geliştirme",
      "photoUrl": "https://cdn.site/p/104.png",
      "birthPlace": "Adana",
      "birthDate": "1994-04-12",
      "email": "ahmet.yilmaz@sirket.com",
      "phone": "+905550123456"
    }
    """
    birthDate = serializers.DateField(format="%Y-%m-%d", input_formats=["%Y-%m-%d"])

    class Meta:
        model = Person
        fields = [
            'id',
            'fullName',
            'department',
            'photoUrl',
            'birthPlace',
            'birthDate',
            'email',
            'phone',
        ]
        read_only_fields = ['id']
