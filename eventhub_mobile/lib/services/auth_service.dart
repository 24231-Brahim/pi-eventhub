import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  Future<AuthResponse> login(String email, String password) async {
    final response = await ApiService.post(
      '/auth/login',
      {'email': email, 'password': password},
      authenticated: false,
    );
    final data = ApiService.parseResponse(response) as Map<String, dynamic>;
    final auth = AuthResponse.fromJson(data);
    await ApiService.saveToken(auth.token);
    return auth;
  }

  Future<AuthResponse> register(
      String name, String email, String password, String role) async {
    final response = await ApiService.post(
      '/auth/register',
      {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      },
      authenticated: false,
    );
    final data = ApiService.parseResponse(response) as Map<String, dynamic>;
    final auth = AuthResponse.fromJson(data);
    await ApiService.saveToken(auth.token);
    return auth;
  }

  Future<void> logout() async {
    await ApiService.clearToken();
  }
}
