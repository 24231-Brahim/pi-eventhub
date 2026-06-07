class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8080/api';
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String refreshToken = '$auth/refresh-token';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';
  static const String logout = '$auth/logout';
  static const String events = '/events';
  static const String bookings = '/bookings';
  static const String tickets = '/tickets';
  static const String payments = '/payments';
  static const String notifications = '/notifications';
  static const String users = '/users';
  static const String dashboard = '/dashboard';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
