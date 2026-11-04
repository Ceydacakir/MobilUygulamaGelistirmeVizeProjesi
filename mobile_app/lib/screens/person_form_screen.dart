import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';

/// 3. EKRAN: Kişi Ekleme / Güncelleme Form Ekranı
/// - Kişi parametresi boşsa: POST /api/persons ile YENİ KAYIT oluşturur.
/// - Kişi parametresi doluysa: PUT /api/persons/{id} ile BİLGİLERİ GÜNCELLER.
class PersonFormScreen extends StatefulWidget {
  final Person? person;

  const PersonFormScreen({super.key, this.person});

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _fullNameController;
  late TextEditingController _departmentController;
  late TextEditingController _photoUrlController;
  late TextEditingController _birthPlaceController;
  late TextEditingController _birthDateController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = false;
  bool get _isEditing => widget.person != null;

  @override
  void initState() {
    super.initState();
    final p = widget.person;
    _fullNameController = TextEditingController(text: p?.fullName ?? '');
    _departmentController = TextEditingController(text: p?.department ?? '');
    _photoUrlController = TextEditingController(
      text: p?.photoUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    );
    _birthPlaceController = TextEditingController(text: p?.birthPlace ?? '');
    _birthDateController = TextEditingController(text: p?.birthDate ?? '1995-01-01');
    _emailController = TextEditingController(text: p?.email ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _departmentController.dispose();
    _photoUrlController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Tarih seçici modal
  Future<void> _pickDate() async {
    DateTime initial = DateTime.tryParse(_birthDateController.text) ?? DateTime(1995, 1, 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formatted =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _birthDateController.text = formatted;
      });
    }
  }

  // Formu kaydetme / sunucuya gönderme
  Future<void> _savePerson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final newPerson = Person(
      id: widget.person?.id,
      fullName: _fullNameController.text.trim(),
      department: _departmentController.text.trim(),
      photoUrl: _photoUrlController.text.trim(),
      birthPlace: _birthPlaceController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    try {
      if (_isEditing) {
        // PUT /api/persons/{id}
        await _apiService.updatePerson(widget.person!.id!, newPerson);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kişi başarıyla güncellendi.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // POST /api/persons
        await _apiService.createPerson(newPerson);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yeni kişi başarıyla kaydedildi.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Kişiyi Düzenle' : 'Yeni Kişi Kaydı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Ad Soyad
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Lütfen ad soyad giriniz' : null,
              ),
              const SizedBox(height: 16),

              // 2. Departman
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Departman / Unvan *',
                  prefixIcon: Icon(Icons.business_center),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Lütfen departman giriniz' : null,
              ),
              const SizedBox(height: 16),

              // 3. Doğum Yeri
              TextFormField(
                controller: _birthPlaceController,
                decoration: const InputDecoration(
                  labelText: 'Doğum Yeri *',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Lütfen doğum yeri giriniz' : null,
              ),
              const SizedBox(height: 16),

              // 4. Doğum Tarihi
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Doğum Tarihi (YYYY-AA-GG) *',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.date_range),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Lütfen doğum tarihi seçiniz' : null,
              ),
              const SizedBox(height: 16),

              // 5. E-posta
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-Posta *',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Lütfen e-posta giriniz';
                  if (!val.contains('@') || !val.contains('.')) return 'Geçerli bir e-posta giriniz';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 6. Telefon
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon *',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Lütfen telefon giriniz' : null,
              ),
              const SizedBox(height: 16),

              // 7. Fotoğraf URL
              TextFormField(
                controller: _photoUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Fotoğraf URL (İsteğe Bağlı)',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 28),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isEditing ? 'GÜNCELLEMEYİ KAYDET' : 'KİŞİYİ KAYDET',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isLoading ? null : _savePerson,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
