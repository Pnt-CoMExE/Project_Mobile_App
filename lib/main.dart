// Refactored main.dart - central routes and role-aware navigation
import 'package:flutter/material.dart';
import 'package:project_mobile_app/student/welcome.dart';
import 'package:project_mobile_app/student/login.dart';
import 'package:project_mobile_app/student/register.dart';
import 'package:project_mobile_app/staff/sdashboard.dart';
import 'package:project_mobile_app/lender/ldashboard.dart';
import 'package:project_mobile_app/student/home.dart';

void main() {
  runApp(const SportBorrowingApp());
}

class SportBorrowingApp extends StatelessWidget {
  const SportBorrowingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sport Borrowing',
      debugShowCheckedModeBanner: false,

      // [FIX] เพิ่มการตั้งค่า Theme ตรงนี้
      theme: ThemeData(
        // 1. กำหนดสีพื้นหลังหลักของทุก Scaffold (ทุกหน้า)
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),

        // 2. (แนะนำ) กำหนดสี AppBar หลักให้เป็นสีม่วง
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white, // สีตัวอักษรและไอคอนบน AppBar
        ),

        // 3. บังคับให้แอปใช้ Light Theme (ป้องกัน Dark Mode อัตโนมัติ)
        brightness: Brightness.light,
      ),

      // [END FIX]
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/student/home': (context) => const HomePage(),
        '/staff/dashboard': (context) => const Sdashboard(),
        '/lender/dashboard': (context) => const Ldashboard(),
      },
    );
  }
}
