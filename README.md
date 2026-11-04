# Kişi Yönetim Sistemi (Client-Server REST Mimarisi)

**Mobil Programlama Dersi — Proje Çalışması**  
_Dönem: 2026-2027 Güz_

---

## 1. Proje Genel Bakışı ve Mimarisi


- **Mobil İstemci (Frontend):** Flutter (Dart).
- **Sunucu Katmanı (Backend):** Django REST Framework (DRF / Python).
- **Ağ Protokolü & İletişim:** JSON gövdeli RESTful HTTP istekleri (`GET`, `POST`, `PUT`, `DELETE`).

---

## 2. Dizin Yapısı

Proje iki ana kök klasöre ayrılmıştır:

```text
MobilUygulamaGelistirmeProjesi/
│
├── backend_api/                  # Django REST Framework Web API
│   ├── backend_api/              # Django proje ayarları (settings, urls, wsgi)
│   ├── persons/                  # Kişi uygulaması (models, serializers, views, urls, admin)
│   │   ├── management/commands/  # seed_data.py (Örnek başlangıç verileri)
│   │   └── tests.py              # Otomatik CRUD birim testleri (5 test)
│   ├── db.sqlite3                # Hazır veritabanı dosyası
│   ├── manage.py
│   └── requirements.txt          # Gerekli python paketleri
│
├── mobile_app/                   # Flutter Mobil Uygulaması
│   ├── lib/
│   │   ├── main.dart             # Uygulama başlangıcı ve tema ayarları
│   │   ├── models/
│   │   │   └── person.dart       # JSON şeması ile 1-e-1 uyumlu model
│   │   ├── services/
│   │   │   └── api_service.dart  # REST API HTTP istekleri (CRUD)
│   │   └── screens/
│   │       ├── person_list_screen.dart   # 1. Ekran: Ana Sayfa (ListView, FAB, Dairesel Avatar)
│   │       ├── person_detail_screen.dart # 2. Ekran: Detay Sayfası (Büyük foto, Intentler, Düzenle/Sil)
│   │       └── person_form_screen.dart   # 3. Ekran: Ekleme & Düzenleme Formu
│   ├── android/                  # Android derleme ve izin ayarları (INTERNET, tel/mailto intentleri)
│   └── pubspec.yaml              # Flutter bağımlılıkları (http, url_launcher)
│
└── README.md                     # Kurulum ve Çalıştırma Kılavuzu (Bu dosya)
```

---

## 3. REST API Uç Noktaları ve Veri Şeması

| Metot      | Uç Nokta            | İşlem / Görev Açıklaması                              |
| :--------- | :------------------ | :---------------------------------------------------- |
| **GET**    | `/api/persons`      | Tüm kişileri dizi (array) formatında listeler.        |
| **GET**    | `/api/persons/{id}` | Belirtilen ID'ye sahip kişinin tüm detaylarını döner. |
| **POST**   | `/api/persons`      | Yeni kişi kaydı oluşturur (Gövde: JSON).              |
| **PUT**    | `/api/persons/{id}` | Kişinin iletişim ve unvan bilgilerini günceller.      |
| **DELETE** | `/api/persons/{id}` | İlgili kaydı veritabanından kalıcı olarak siler.      |

### Örnek Kişi JSON Şeması (Payload):

```json
{
    "id": 104,
    "fullName": "Ahmet Yılmaz",
    "department": "Yazılım Geliştirme",
    "photoUrl": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400",
    "birthPlace": "Adana",
    "birthDate": "1994-04-12",
    "email": "ahmet.yilmaz@sirket.com",
    "phone": "+905550123456"
}
```

---

## 4. Adım Adım Kurulum ve Çalıştırma Kılavuzu

### ADIM 1: Backend API Servisinin Başlatılması (Python 3.10+ gerekir)

1. Bir terminal (PowerShell veya CMD) açın ve `backend_api` dizinine girin:

    ```bash
    cd "backend_api"
    ```

2. Proje için sanal ortam (venv) oluşturun:

    ```bash
    python -m venv venv
    ```

3. Sanal ortamı aktifleştirin:

    ```bash
    # Windows (PowerShell) için:
    .\venv\Scripts\Activate.ps1
    ```

    ```bash
    # Windows (CMD) için:
    venv\Scripts\activate.bat
    ```

    ```bash
    # Mac / Linux için:
    source venv/bin/activate
    ```

4. Gerekli Python paketlerini yükleyin (daha önce yüklendiyse atlayabilirsiniz):

    ```bash
    pip install -r requirements.txt
    ```

5. Veritabanı tablolarını oluşturun ve örnek veriler sql içinde hazır:

    ```bash
    python manage.py migrate
    ```

6. Django geliştirme sunucusunu tüm ağ arayüzlerine açık olacak şekilde (`0.0.0.0:8000`) başlatın:
    ```bash
    python manage.py runserver 0.0.0.0:8000
    ```
    > Sunucu başladığında tarayıcınızdan `http://127.0.0.1:8000/api/persons` adresine giderek API'nin canlı çalıştığını görebilirsiniz.

---

### ADIM 2: Mobil Uygulamanın (Flutter) Çalıştırılması

Mobil uygulamanın çalıştırılacağı ortama göre `mobile_app/lib/services/api_service.dart` dosyasındaki `baseUrl` otomatik veya manuel ayarlanabilir:

- **Google Chrome / Web:** Otomatik olarak `http://127.0.0.1:8000/api` kullanır.
- **Android Emülatör:** Otomatik olarak `http://10.0.2.2:8000/api` (Android'in ana makineye erişim IP'si) kullanır.
- **Fiziksel Telefon (USB veya Wi-Fi):** Bilgisayarınızın yerel IP adresini yazın (Örn: `http://192.168.1.105:8000/api`).

#### Uygulamayı Başlatma Seçenekleri:

1. İkinci bir terminal açın ve `mobile_app` klasörüne gidin:

    ```bash
    cd "mobile_app"
    ```

2. Paketleri kontrol edin:

    ```bash
    flutter pub get
    ```

3. **Seçenek A — Tarayıcıda Çalıştırma (En Hızlı Sunum Şekli):**

    ```bash
    flutter run -d chrome
    ```

4. **Seçenek B — Windows Masaüstü Olarak Çalıştırma:**

    ```bash
    flutter run -d windows
    ```

5. **Seçenek C — Android Cihazda / Emülatörde Çalıştırma:**
    ```bash
    flutter run
    ```

---

## 5. Testlerin Çalıştırılması

- **Backend Birim Testleri (Django REST):**

    ```bash
    cd backend_api
    python manage.py test persons
    ```

    _(5 test: Listeleme, Detay Getirme, Ekleme, Güncelleme ve Silme uç noktalarını doğrular)._

- **Mobil Uygulama Testleri (Flutter):**
    ```bash
    cd mobile_app
    flutter test
    ```

---
