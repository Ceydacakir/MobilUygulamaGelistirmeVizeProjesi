"""
Django settings for backend_api project.
Vize Projesi: Kişi Yönetim Sistemi (Client-Server REST Mimarisi)
"""

from pathlib import Path

# Projenin temel dizini (backend_api)
BASE_DIR = Path(__file__).resolve().parent.parent

# Güvenlik Anahtarı (Geliştirme ortamı için)
SECRET_KEY = 'django-insecure-vize-projesi-kisi-yonetim-sistemi-secret-key'

# Hata ayıklama modu geliştirme aşamasında açık
DEBUG = True

# Mobil istemcilerin (emülatör, yerel ağ veya localhost) bağlanabilmesi için tüm hostlara izin verilir
ALLOWED_HOSTS = ['*']

# Uygulama Tanımları
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Üçüncü Parti Paketler
    'corsheaders',          # Mobil ve web istemcilerinin CORS kısıtlamasına takılmaması için
    'rest_framework',       # Django REST Framework (JSON REST API oluşturmak için)
    
    # Bizim Uygulamamız
    'persons',              # Kişi modelleri, görünümleri ve API uç noktaları
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # CORS ara katmanı (En üstte yer almalıdır)
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'backend_api.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'backend_api.wsgi.application'

# Veritabanı: Ek kurulum gerektirmeyen SQLite3 veritabanı
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Şifre Doğrulama Kuralları
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# Uluslararasılaştırma
LANGUAGE_CODE = 'tr-tr'
TIME_ZONE = 'Europe/Istanbul'
USE_I18N = True
USE_TZ = True

# Statik Dosyalar (CSS, JavaScript, Images)
STATIC_URL = 'static/'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# CORS Ayarları: Mobil istemcilerden (Flutter, React Native vb.) gelen tüm isteklere izin verilir
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]
CORS_ALLOW_HEADERS = [
    '*',
]

# Django REST Framework Ayarları
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny', # Vize projesinde açık API kullanımı
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer', # Tarayıcıdan test edebilmek için
    ],
}
