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
