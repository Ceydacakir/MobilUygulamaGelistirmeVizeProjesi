/// PDF Yönergesindeki JSON Şeması ile 1-e-1 Uyumlu Kişi Modeli
///
/// Örnek JSON Payload:
/// {
///   "id": 104,
///   "fullName": "Ahmet Yılmaz",
///   "department": "Yazılım Geliştirme",
///   "photoUrl": "https://cdn.site/p/104.png",
///   "birthPlace": "Adana",
///   "birthDate": "1994-04-12",
///   "email": "ahmet.yilmaz@sirket.com",
///   "phone": "+905550123456"
/// }
class Person {
  final int? id;
  final String fullName;
  final String department;
  final String photoUrl;
  final String birthPlace;
  final String birthDate;
  final String email;
  final String phone;

  Person({
    this.id,
    required this.fullName,
    required this.department,
    required this.photoUrl,
    required this.birthPlace,
    required this.birthDate,
    required this.email,
    required this.phone,
  });

  /// Sunucudan (API) gelen JSON verisini Person Dart nesnesine dönüştürür
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int?,
      fullName: json['fullName'] as String? ?? '',
      department: json['department'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      birthPlace: json['birthPlace'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  /// Person Dart nesnesini sunucuya (POST/PUT) göndermek üzere JSON Haritasına (Map) çevirir
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'fullName': fullName,
      'department': department,
      'photoUrl': photoUrl,
      'birthPlace': birthPlace,
      'birthDate': birthDate,
      'email': email,
      'phone': phone,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  /// Mevcut nesnenin kopyasını alıp belirli alanları güncellemek için kullanılır
  Person copyWith({
    int? id,
    String? fullName,
    String? department,
    String? photoUrl,
    String? birthPlace,
    String? birthDate,
    String? email,
    String? phone,
  }) {
    return Person(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      department: department ?? this.department,
      photoUrl: photoUrl ?? this.photoUrl,
      birthPlace: birthPlace ?? this.birthPlace,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
