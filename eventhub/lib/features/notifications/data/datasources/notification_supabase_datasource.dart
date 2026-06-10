import 'package:supabase_flutter/supabase_flutter.dart';

abstract class NotificationSupabaseDataSource {
  Future<List<Map<String, dynamic>>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
}

class NotificationSupabaseDataSourceImpl
    implements NotificationSupabaseDataSource {
  final SupabaseClient supabase;

  NotificationSupabaseDataSourceImpl({required this.supabase});

  @override
  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map((e) => _toCamelCase(e)).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Map<String, dynamic> _toCamelCase(Map<String, dynamic> snake) {
    return {
      'id': snake['id'],
      'userId': snake['user_id'],
      'title': snake['title'],
      'body': snake['body'],
      'type': snake['type'],
      'data': snake['data'],
      'isRead': snake['is_read'],
      'createdAt': snake['created_at'],
    };
  }
}
