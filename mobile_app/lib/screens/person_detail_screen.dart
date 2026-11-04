import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/person.dart';
import '../services/api_service.dart';
import 'person_form_screen.dart';

/// 2. EKRAN: Kişi Detay Sayfası
/// PDF Yönergesi Gereksinimleri:
/// - ID Bazlı Veri: Sayfa açıldığında verilen ID ile GET /api/persons/{id} çağrılır.
/// - Görsel & Bilgi Hiyerarşisi: Üstte büyük profil fotoğrafı, merkezde Ad-Soyad ve Departman unvanı;
///   alt panelde kartlar/satırlar halinde Doğum Yeri, Doğum Tarihi, E-posta ve Telefon.
/// - İletişim Aksiyonları: E-posta ve telefon satırları tıklanabilir olmalı; url_launcher ile posta ve arama intent'lerini tetikler.
/// - Aksiyon Butonları (En Altta Sabit):
///   * Düzenle (Edit): Bilgileri güncelleme ekranına taşır.
///   * Sil (Delete): Kullanıcıdan onay diyaloğu alarak API'ye DELETE isteği yollar ve listeye döner.
class PersonDetailScreen extends StatefulWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Person> _personFuture;
  Person? _loadedPerson;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadPersonDetails();
  }

  // Kişinin tüm detaylarını API'den çeker
  void _loadPersonDetails() {
    setState(() {
      _personFuture = _apiService.getPersonById(widget.personId);
    });
  }

  // Telefon arama niyetini (intent) tetikler
  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanedNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arama başlatılamadı: $e')),
        );
      }
    }
  }

  // E-posta gönderme niyetini (intent) tetikler
  Future<void> _sendEmail(String emailAddress) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('E-posta uygulaması açılamadı: $e')),
        );
      }
    }
  }

  // Silme Onay Diyaloğu Gösterir ve DELETE isteği gönderir
  Future<void> _confirmAndDelete() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Kişiyi Sil'),
          content: Text(
            '${_loadedPerson?.fullName ?? "Bu kişiyi"} rehberden kalıcı olarak silmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        _isDeleting = true;
      });

      try {
        await _apiService.deletePerson(widget.personId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kişi başarıyla silindi.'),
              backgroundColor: Colors.green,
            ),
          );
          // Listeye geri döner ve listenin yenilenmesi için true bayrağını iletir
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        setState(() {
          _isDeleting = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silme başarısız: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişi Detay Bilgileri'),
      ),
      body: FutureBuilder<Person>(
        future: _personFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Detaylar getirilemedi: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPersonDetails,
                    child: const Text('Yeniden Dene'),
                  ),
                ],
              ),
            );
          }

          final person = snapshot.data!;
          _loadedPerson = person;

          return Column(
            children: [
              // Kaydırılabilir içerik paneli (Fotoğraf, Ad-Soyad, Bilgi Kartları)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // PDF Kuralı: Üstte büyük profil fotoğrafı
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: person.photoUrl.isNotEmpty
                            ? NetworkImage(person.photoUrl)
                            : null,
                        child: person.photoUrl.isEmpty
                            ? Text(
                                person.fullName.isNotEmpty ? person.fullName[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // PDF Kuralı: Merkezde Ad-Soyad ve Departman unvanı
                      Text(
                        person.fullName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        person.department,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.blueGrey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Alt Panel Bilgi Kartları
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              // 1. Doğum Yeri ve Doğum Tarihi Satırı
                              ListTile(
                                leading: const Icon(Icons.cake, color: Colors.indigo),
                                title: const Text(
                                  'Doğum Yeri / Tarihi',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                subtitle: Text(
                                  '${person.birthPlace} | ${person.birthDate}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const Divider(height: 1, indent: 64),

                              // 2. PDF Kuralı: E-posta satırı tıklanabilir (intent)
                              ListTile(
                                leading: const Icon(Icons.email, color: Colors.deepOrange),
                                title: const Text(
                                  'E-Posta (Göndermek için dokunun)',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                subtitle: Text(
                                  person.email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                                trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
                                onTap: () => _sendEmail(person.email),
                              ),
                              const Divider(height: 1, indent: 64),

                              // 3. PDF Kuralı: Telefon satırı tıklanabilir (intent)
                              ListTile(
                                leading: const Icon(Icons.phone, color: Colors.green),
                                title: const Text(
                                  'Telefon (Aramak için dokunun)',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                subtitle: Text(
                                  person.phone,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                                trailing: const Icon(Icons.call, size: 18, color: Colors.green),
                                onTap: () => _makePhoneCall(person.phone),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // PDF Kuralı: Aksiyon Butonları (En Altta Sabit Panel)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Düzenle (Edit) Butonu
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text(
                            'DÜZENLE',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PersonFormScreen(person: person),
                              ),
                            );
                            if (updated == true) {
                              _loadPersonDetails();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Sil (Delete) Butonu
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.delete),
                          label: const Text(
                            'KİŞİYİ SİL',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _isDeleting ? null : _confirmAndDelete,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
