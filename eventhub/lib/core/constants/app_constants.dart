class AppConstants {
  AppConstants._();

  static const String appName = 'EventHub';
  static const String appVersion = '1.0.0';
  static const String localeKey = 'locale';
  static const String themeKey = 'theme_mode';
  static const String tokenKey = 'jwt_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String onboardingKey = 'onboarding_completed';
  static const String userKey = 'current_user';

  static const int minPasswordLength = 8;
  static const int maxEventTitleLength = 100;
  static const int maxEventDescriptionLength = 2000;
  static const int defaultPageSize = 20;
}
