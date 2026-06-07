import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:eventhub/core/constants/app_constants.dart';

class TokenManager {
  final FlutterSecureStorage _storage;
  TokenManager({required this._storage});

  Future<void> saveToken(String token) async =>
      await _storage.write(key: AppConstants.tokenKey, value: token);

  Future<String?> getToken() async =>
      await _storage.read(key: AppConstants.tokenKey);

  Future<void> saveRefreshToken(String token) async =>
      await _storage.write(key: AppConstants.refreshTokenKey, value: token);

  Future<String?> getRefreshToken() async =>
      await _storage.read(key: AppConstants.refreshTokenKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
}
