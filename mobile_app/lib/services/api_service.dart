import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/person.dart';

/// REST API Servisi
/// Bu sınıf mobil istemci ile Django REST API arasındaki HTTP/REST iletişimini yönetir.
/// tüm uç noktaları (GET, POST, PUT, DELETE) eksiksiz içerir.
class ApiService {
  // IP Ayarı:
  // - Android Emülatör için: 'http://10.0.2.2:8000/api'
  // - Web / Windows Masaüstü / iOS Simülatör için: 'http://127.0.0.1:8000/api'
  // - Fiziksel Cihaz için: Bilgisayarınızın yerel IP'si (Örn: 'http://192.168.1.105:8000/api')
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator'ünün ana makineye erişim adresi.
        return 'http://10.0.2.2:8000/api';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:8000/api';
    }
  }

  // İstek başlıkları (JSON formatında veri transferi)
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

  /// 1. GET /api/persons
  /// Tüm kişileri dizi (array) formatında listeler.
  Future<List<Person>> getPersons() async {
    final response = await http.get(
      Uri.parse('$baseUrl/persons'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Person.fromJson(item)).toList();
    } else {
      throw Exception('Kişiler yüklenirken hata oluştu (Kod: ${response.statusCode})');
    }
  }

  /// 2. GET /api/persons/{id}
  /// Belirtilen ID'ye sahip kişinin tüm detaylarını döner.
  Future<Person> getPersonById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/persons/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return Person.fromJson(body);
    } else {
      throw Exception('Kişi detayı bulunamadı (Kod: ${response.statusCode})');
    }
  }

  /// 3. POST /api/persons
  /// Yeni kişi kaydı oluşturur (Gövde olarak JSON gönderir).
  Future<Person> createPerson(Person person) async {
    final response = await http.post(
      Uri.parse('$baseUrl/persons'),
      headers: _headers,
      body: jsonEncode(person.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return Person.fromJson(body);
    } else {
      throw Exception('Kişi eklenirken hata oluştu (Kod: ${response.statusCode})');
    }
  }

  /// 4. PUT /api/persons/{id}
  /// Kişinin iletişim ve unvan bilgilerini günceller.
  Future<Person> updatePerson(int id, Person person) async {
    final response = await http.put(
      Uri.parse('$baseUrl/persons/$id'),
      headers: _headers,
      body: jsonEncode(person.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return Person.fromJson(body);
    } else {
      throw Exception('Kişi güncellenirken hata oluştu (Kod: ${response.statusCode})');
    }
  }

  /// 5. DELETE /api/persons/{id}
  /// İlgili kaydı veritabanından kalıcı olarak siler.
  Future<bool> deletePerson(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/persons/$id'),
      headers: _headers,
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Kişi silinirken hata oluştu (Kod: ${response.statusCode})');
    }
  }
}
