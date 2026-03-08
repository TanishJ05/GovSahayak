// frontend/lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login/login_screen.dart';

void main() {
  runApp(const SenateBotApp());
}

class SenateBotApp extends StatelessWidget {
  const SenateBotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Senate Bot',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primaryColor: const Color(0xFF1A3C6E), // Hardcoded Deep Blue
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Hardcoded Light Grey
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3C6E)),
        useMaterial3: true,
      ),
      home: const LoginScreen(), 
    );
  }
}