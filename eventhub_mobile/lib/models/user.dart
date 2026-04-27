class User {
  final int id;
  final String name;
  final String email;
  final String role; // "ORGANIZER" | "GUEST"

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isOrganizer => role == 'ORGANIZER';

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      };
}

class AuthResponse {
  final String token;
  final String email;
  final String name;
  final String role;

  const AuthResponse({
    required this.token,
    required this.email,
    required this.name,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
      );
}
