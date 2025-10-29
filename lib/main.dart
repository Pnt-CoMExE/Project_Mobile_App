//main.dart

import 'package:flutter/material.dart';
import 'package:project_mobile_app/staff/dashboard.dart';
import 'package:project_mobile_app/staff/login.dart'; 

void main() {
  runApp(const SportBorrowingApp());
}

class SportBorrowingApp extends StatelessWidget {
  const SportBorrowingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 🔹 เริ่มต้นที่หน้า Login
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginStuden(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}