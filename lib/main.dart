import 'package:flutter/material.dart';
import 'package:project_mobile_app/lender/approve.dart';
import 'package:project_mobile_app/lender/dashboard.dart';
import 'package:project_mobile_app/lender/history.dart';
import 'package:project_mobile_app/lender/login.dart'; // ✅ อย่าลืม import หน้า dashboard ด้วย

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
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/login':
            page = const LoginStuden();
            break;
          case '/dashboard':
            page = const DashboardPage();
            break;
           case '/approve':
           page = const ApproveListPage();
           break;
           case '/history':
           page = const HistoryPage();
           break;
          default:
            page = const DashboardPage();
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => page,
        );
      },
    );
  }
import 'package:project_mobile_app/student/home.dart';

void main() {
  runApp(MaterialApp(home: Home(), debugShowCheckedModeBanner: false));
}
          
        //'/login': (context) => const LoginStuden(),
        //'/dashboard': (context) => const DashboardPage(),
        //'/approve': (context) => const ApproveListPage(),
