from django.urls import path, re_path
from .views import PersonListCreateView, PersonDetailView

urlpatterns = [
    # GET  /api/persons     -> Kişileri listele
    # POST /api/persons     -> Yeni kişi ekle
    re_path(r'^persons/?$', PersonListCreateView.as_view(), name='person-list-create'),

    # GET    /api/persons/{id} -> Kişi detaylarını getir
    # PUT    /api/persons/{id} -> Kişiyi güncelle
    # DELETE /api/persons/{id} -> Kişiyi sil
    re_path(r'^persons/(?P<pk>\d+)/?$', PersonDetailView.as_view(), name='person-detail'),
]
