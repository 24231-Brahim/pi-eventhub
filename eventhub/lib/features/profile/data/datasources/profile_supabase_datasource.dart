import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileSupabaseDataSource {
  Future<Map<String, dynamic>> getProfile(String userId);
  Future<Map<String, dynamic>> updateProfile(
      String userId, String name, String? phone, String? photoUrl);
}

class ProfileSupabaseDataSourceImpl implements ProfileSupabaseDataSource {
  final SupabaseClient supabase;

  ProfileSupabaseDataSourceImpl({required this.supabase});

  @override
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return _toCamelCase(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        final user = supabase.auth.currentUser;
        final email = user?.email ?? '';
        final meta = user?.userMetadata ?? {};
        final role = meta['role'] as String? ?? 'participant';
        final newProfile = await supabase
            .from('profiles')
            .insert({
              'id': userId,
              'email': email,
              'name': email.split('@').first,
              'role': role,
            })
            .select()
            .single();
        return _toCamelCase(newProfile);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile(
      String userId, String name, String? phone, String? photoUrl) async {
    final data = <String, dynamic>{'name': name};
    if (phone != null) data['phone'] = phone;
    if (photoUrl != null) data['photo_url'] = photoUrl;

    try {
      final response = await supabase
          .from('profiles')
          .update(data)
          .eq('id', userId)
          .select()
          .single();
      return _toCamelCase(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        final user = supabase.auth.currentUser;
        final email = user?.email ?? '';
        final meta = user?.userMetadata ?? {};
        data['id'] = userId;
        data['email'] = email;
        data['role'] = meta['role'] as String? ?? 'participant';
        final newProfile = await supabase
            .from('profiles')
            .insert(data)
            .select()
            .single();
        return _toCamelCase(newProfile);
      }
      rethrow;
    }
  }

  Map<String, dynamic> _toCamelCase(Map<String, dynamic> snake) {
    return {
      'id': snake['id'],
      'email': snake['email'],
      'name': snake['name'],
      'phone': snake['phone'],
      'photoUrl': snake['photo_url'],
      'role': snake['role'],
      'createdAt': snake['created_at'],
    };
  }
}
