import 'package:eventhub/core/constants/api_constants.dart';
import 'package:eventhub/core/network/api_client.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getProfile();
  Future<Map<String, dynamic>> updateProfile(
      String name, String? phone, String? photoUrl);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;
  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getProfile() async {
    final response = await apiClient.get('${ApiConstants.users}/profile');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateProfile(
      String name, String? phone, String? photoUrl) async {
    final response =
        await apiClient.put('${ApiConstants.users}/profile', data: {
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
    });
    return response.data as Map<String, dynamic>;
  }
}
