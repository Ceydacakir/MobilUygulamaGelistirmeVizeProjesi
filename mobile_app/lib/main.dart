import 'package:flutter/material.dart';
import 'screens/person_list_screen.dart';

void main() {
  runApp(const PersonManagementApp());
}

class PersonManagementApp extends StatelessWidget {
  const PersonManagementApp({super.key});  //super.key parametresi, PersonManagementApp widget'ının bir üst widget tarafından oluşturulurken verilen key değerini almasını sağlar. Bu, widget'ın kimliğini belirlemek ve widget ağacında doğru şekilde yönetilmesini sağlamak için kullanılır.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kişi Yönetim Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5), // Modern Material Blue
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 2,
          centerTitle: true,
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const PersonListScreen(),
    );
  }
}
