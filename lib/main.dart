import 'package:flutter/material.dart';
import 'package:project_mobile_app/student/login.dart';
import 'student/welcome.dart';
import 'student/register.dart';



void main() {
  runApp(SportEquipmentApp());
}

class SportEquipmentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sport Equipment Borrowing',
      debugShowCheckedModeBanner: false,
     theme: ThemeData(primarySwatch: Colors.purple, fontFamily: 'Poppins'),
     initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}



