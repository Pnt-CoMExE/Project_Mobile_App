import 'package:project_mobile_app/models/user.dart';
import 'api_service.dart';

class AuthService {
  static Future<User> login(String username, String password) async {
    final res = await ApiService.post('login.php', {'username': username, 'password': password});
    if (res['success'] == true) {
      return User.fromJson(res['user']);
    } else {
      throw Exception(res['message'] ?? 'Login failed');
    }
  }

  static Future<User> register(String username, String password, String fullname) async {
    // force role to student
    final res = await ApiService.post('register.php', {
      'username': username,
      'password': password,
      'fullname': fullname,
      'role': 'student',
    });
    if (res['success'] == true) {
      return User.fromJson(res['user']);
    } else {
      throw Exception(res['message'] ?? 'Register failed');
    }
  }
}
