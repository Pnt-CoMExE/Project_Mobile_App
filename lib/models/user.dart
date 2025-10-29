class User {
  final int? id;
  final String username;
  final String role;
  final String? token;

  User({this.id, required this.username, required this.role, this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      username: json['username'] ?? '',
      role: json['role'] ?? 'student',
      token: json['token'],
    );
  }
}
