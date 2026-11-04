import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';

/// 1. EKRAN: Kişi Listesi (Ana Sayfa)
/// PDF Yönergesi Gereksinimleri:
/// - Dinamik Liste: API'deki /api/persons ucundan çekilen veriler kaydırılabilir liste (ListView) içinde listelenir.
/// - Satır/Kart Elemanları: Solda dairesel profil fotoğrafı (ağ resmi), yanında kalın yazı tipiyle Ad-Soyad ve altında Departman bilgisi.
/// - Floating Action Button (FAB): Ekranın sağ alt köşesinde sabit '+' simgeli buton. Tıklandığında yeni kişi kayıt ekranını açar.
/// - Gezinim (Navigation): Listeden bir satıra tıklandığında seçilen kişinin benzersiz ID'si ile Detay Sayfası açılır.
class PersonListScreen extends StatefulWidget {
  const PersonListScreen({super.key});

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Person>> _personsFuture; //future tipinde bir değişken, API'den asenkron olarak çekilen kişi listesini temsil eder. Future, gelecekte tamamlanacak bir işlemi temsil eder ve bu durumda API çağrısı sonucunda dönecek olan kişi listesi.
// neden gelecekte tamamlanacak? Çünkü API çağrısı zaman alabilir ve kullanıcı arayüzünü engellememek için Future kullanılır. Bu sayede kullanıcı arayüzü donmaz ve kullanıcıya yükleniyor göstergesi gösterilebilir.
  @override
  void initState() { 
    /* init State() metodu bir kez çağrılır. Bu metot, widget'ın durumunu başlatmak
    ve gerekli başlangıç işlemlerini yapmak için kullanılır. */
    super.initState(); 
    _loadPersons();  // Kişi listesini API'den asenkron olarak yükler neden asenkron? Çünkü API çağrısı zaman alabilir ve kullanıcı arayüzünü engellememek için Future kullanılır.
  } //asenkron olduğunu nasıl anladın? Çünkü _loadPersons() metodu içinde _apiService.getPersons() çağrısı yapılıyor ve bu metodun dönüş tipi Future<List<Person>>. Bu, işlemin tamamlanmasının zaman alabileceğini ve sonuçların gelecekte bir noktada döneceğini gösterir.

  // Kişi listesini API'den asenkron olarak yeniden yükler
  void _loadPersons() {
    setState(() {
      _personsFuture = _apiService.getPersons();
    });
  } // setState() metodu, widget'ın durumunu günceller ve kullanıcı arayüzünü yeniden çizer. Bu sayede Future<List<Person>> tipindeki _personsFuture değişkeni güncellenir ve FutureBuilder widget'ı yeniden çalıştırılır.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rehber / Kişi Listesi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadPersons,
          ),
        ],
      ),
      // Listeyi aşağı çekerek yenileme (Pull to Refresh) özelliği
      body: RefreshIndicator(
        onRefresh: () async {
          _loadPersons();
          await _personsFuture;
        },
        child: FutureBuilder<List<Person>>(
          future: _personsFuture,
          builder: (context, snapshot) {
            // Durum 1: Veriler yükleniyor
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Durum 2: Hata oluştu
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 56, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        'Veri yüklenemedi:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadPersons,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Durum 3: Veri başarıyla geldi fakat liste boş
            final persons = snapshot.data ?? [];
            if (persons.isEmpty) {
              return const Center(
                child: Text(
                  'Henüz kayıtlı kişi bulunmamaktadır.\n(+) butonuna basarak yeni kişi ekleyebilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            // Durum 4: Dinamik kaydırılabilir liste (ListView.builder)
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: persons.length,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemBuilder: (context, index) {
                final person = persons[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    // PDF Kuralı: Solda dairesel profil fotoğrafı (ağ resmi)
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: person.photoUrl.isNotEmpty
                          ? NetworkImage(person.photoUrl)
                          : null,
                      child: person.photoUrl.isEmpty
                          ? Text(
                              person.fullName.isNotEmpty ? person.fullName[0].toUpperCase() : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            )
                          : null,
                    ),
                    // PDF Kuralı: Kalın yazı tipiyle Ad-Soyad
                    title: Text(
                      person.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // PDF Kuralı: Altında Departman bilgisi
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        person.department,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Sağdaki ok simgesi
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    // PDF Kuralı: Listeden bir satıra tıklandığında seçilen kişinin benzersiz ID'si ile Detay Sayfası açılır
                    onTap: () async {
                      if (person.id != null) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonDetailScreen(personId: person.id!),
                          ),
                        );
                        // Detay ekranından dönüldüğünde liste güncellenir (silme veya düzenleme sonrası)
                        if (result == true) {
                          _loadPersons();
                        }
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      // PDF Kuralı: Floating Action Button (FAB) - Ekranın sağ alt köşesinde sabit '+' simgeli buton
      floatingActionButton: FloatingActionButton(
        tooltip: 'Yeni Kişi Ekle',
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PersonFormScreen(),
            ),
          );
          // Yeni kayıt eklendiğinde listeyi otomatik yenile
          if (result == true) {
            _loadPersons();
          }
        },
      ),
      
    );
  }
}
