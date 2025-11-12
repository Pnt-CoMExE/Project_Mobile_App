// Refactored main.dart - central routes and role-aware navigation
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ เพิ่มบรรทัดนี้
import 'package:project_mobile_app/student/welcome.dart';
import 'package:project_mobile_app/student/login.dart';
import 'package:project_mobile_app/student/register.dart';
import 'package:project_mobile_app/staff/sdashboard.dart';
import 'package:project_mobile_app/lender/ldashboard.dart';
import 'package:project_mobile_app/student/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await initializeDateFormatting('th', null); // ✅ โหลด locale ภาษาไทย
  runApp(const SportBorrowingApp());
}

class SportBorrowingApp extends StatelessWidget {
  const SportBorrowingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sport Borrowing',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        brightness: Brightness.light,
      ),

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
