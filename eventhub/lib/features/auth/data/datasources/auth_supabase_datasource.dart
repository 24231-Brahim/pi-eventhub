import 'package:supabase_flutter/supabase_flutter.dart';

class AuthResponse {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? photoUrl;
  final String? phone;
  final String? accessToken;
  final String? refreshToken;

  AuthResponse({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.phone,
    this.accessToken,
    this.refreshToken,
  });

  Map<String, dynamic> toMap() => {
        'user': {
          'id': id,
          'email': email,
          'name': name,
          'role': role,
          'photo_url': photoUrl,
          'phone': phone,
        },
        'session': {
          'access_token': accessToken ?? '',
          'refresh_token': refreshToken ?? '',
        },
      };
}

abstract class AuthSupabaseDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(
      String name, String email, String password, String role);
  Future<void> forgotPassword(String email);
  Future<void> logout();
}

class AuthSupabaseDataSourceImpl implements AuthSupabaseDataSource {
  final GoTrueClient auth;
  final SupabaseClient supabase;

  AuthSupabaseDataSourceImpl({
    required this.auth,
    required this.supabase,
  });

  @override
  Future<AuthResponse> login(String email, String password) async {
    final response = await auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user!;
    final meta = user.userMetadata ?? {};

    Map<String, dynamic> profile = {};
    try {
      profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
    } catch (_) {}

    return AuthResponse(
      id: user.id,
      email: user.email ?? email,
      name: (profile['name'] as String?) ?? (meta['name'] as String?) ?? '',
      role: (profile['role'] as String?) ?? (meta['role'] as String?) ?? 'participant',
      photoUrl: (profile['photo_url'] as String?) ?? (meta['avatar_url'] as String?),
      phone: profile['phone'] as String?,
      accessToken: response.session!.accessToken,
      refreshToken: response.session!.refreshToken,
    );
  }

  @override
  Future<AuthResponse> register(
      String name, String email, String password, String role) async {
    final response = await auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role},
    );

    if (response.session != null) {
      final user = response.user!;
      Map<String, dynamic> profile = {};
      try {
        profile = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
      } catch (_) {}

      return AuthResponse(
        id: user.id,
        email: user.email ?? email,
        name: (profile['name'] as String?) ?? name,
        role: (profile['role'] as String?) ?? role,
        photoUrl: profile['photo_url'] as String?,
        phone: profile['phone'] as String?,
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken,
      );
    }

    throw Exception(
      'Inscription réussie ! Veuillez vérifier votre boîte email pour confirmer votre compte avant de vous connecter.',
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    await auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> logout() async {
    await auth.signOut();
  }
}
