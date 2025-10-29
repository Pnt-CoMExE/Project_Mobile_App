import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // TODO: change host to your machine IP when testing on emulator/device.
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // use 127.0.0.1 for web, 10.0.2.2 for Android emulator

  static Future<Map<String,dynamic>> post(String endpoint, Map<String,dynamic> body) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final resp = await http.post(uri, body: body);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String,dynamic>;
    } else {
      throw Exception('Network error: ${resp.statusCode}');
    }
  }
}
