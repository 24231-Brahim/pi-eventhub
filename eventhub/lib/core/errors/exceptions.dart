class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException({required this.message, this.statusCode});
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  NetworkException({required this.message});
}

class AuthException implements Exception {
  final String message;
  AuthException({required this.message});
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;
  ValidationException({required this.message, this.errors});
}
