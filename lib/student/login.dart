// lib/student/login.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_mobile_app/config/ip.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$kAuthApiBaseUrl/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'u_username': _usernameController.text.trim(),
          'u_password': _passwordController.text.trim(),
        }),
      );

      debugPrint("📥 Login Response (${response.statusCode}): ${response.body}");

      if (!mounted) return;

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Invalid response from server')),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (response.statusCode == 200 && data!['success'] == true) {
  final prefs = await SharedPreferences.getInstance();

  int userId = data!['user']['u_id'];
  int userRole = data!['user']['u_role'];
  String username = data!['user']['u_username'];
  String token = data!['user']['token'] ?? '';


        // ✅ บันทึกลง SharedPreferences (ใช้ key เดียวกับทุกหน้า)
        await prefs.setInt('u_id', userId);
        await prefs.setInt('u_role', userRole);
        await prefs.setString('u_username', username);
        await prefs.setString('token', token);

        debugPrint(
            "✅ Saved user info: u_id=$userId, u_role=$userRole, u_username=$username");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Login successful!')),
        );

        if (!mounted) return;

        // ✅ ไปยังหน้าตาม role
        if (userRole == 1) {
          Navigator.pushReplacementNamed(context, '/student/home');
        } else if (userRole == 2) {
          Navigator.pushReplacementNamed(context, '/staff/dashboard');
        } else if (userRole == 3) {
          Navigator.pushReplacementNamed(context, '/lender/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unknown role, please contact admin.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${data!['message']}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/'),
                  child: const Text(
                    "< Back",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 500,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 40,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Sign in",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Color.fromARGB(255, 129, 56, 189),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: "Username",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? "Please enter username"
                                : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? "Please enter password"
                                : null,
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : loginUser,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.transparent,
                                elevation: 4,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFA25AC3),
                                      Color(0xFF4F1C7B),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Login",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              "Create new account",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Color.fromARGB(255, 129, 56, 189),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}