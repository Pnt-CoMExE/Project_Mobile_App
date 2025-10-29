import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'student/welcome.dart';
import 'student/login.dart';
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
=======
import 'package:project_mobile_app/student/home.dart';

void main() {
  runApp(MaterialApp(home: Home(), debugShowCheckedModeBanner: false));
>>>>>>> a9eb85052ca3cd4fcc7f50cbea441d8e0ad93cee
}
