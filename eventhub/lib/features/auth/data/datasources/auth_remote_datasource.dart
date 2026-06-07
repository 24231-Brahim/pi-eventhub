import 'package:eventhub/core/constants/api_constants.dart';
import 'package:eventhub/core/network/api_client.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(
      String name, String email, String password, String role);
  Future<void> forgotPassword(String email);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await apiClient.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    final response = await apiClient.post(ApiConstants.register, data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await apiClient.post(ApiConstants.forgotPassword, data: {
      'email': email,
    });
  }

  @override
  Future<void> logout() async {
    await apiClient.post(ApiConstants.logout);
  }
}
