import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AdminSupabaseDataSource {
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<Map<String, dynamic>>> getUsers();
  Future<void> updateUserRole(String userId, String newRole);
  Future<void> toggleUserActive(String userId);
  Future<List<Map<String, dynamic>>> getAllEvents();
  Future<void> approveEvent(String eventId, {bool approved = true, String? reason});
  Future<void> toggleEventFeatured(String eventId);
  Future<void> deleteEvent(String eventId);
  Future<List<Map<String, dynamic>>> getAllBookings();
  Future<List<Map<String, dynamic>>> getAllTickets();
}

class AdminSupabaseDataSourceImpl implements AdminSupabaseDataSource {
  final SupabaseClient supabase;

  AdminSupabaseDataSourceImpl({required this.supabase});

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    final results = await Future.wait([
      supabase.from('profiles').select('id, role'),
      supabase.from('events').select('id, status'),
      supabase.from('bookings').select('id, total_amount'),
      supabase.from('tickets').select('id'),
    ]);

    final users = results[0] as List;
    final events = results[1] as List;
    final bookings = results[2] as List;
    final tickets = results[3] as List;

    int admins = 0, organizers = 0, participants = 0;
    for (final u in users) {
      final role = (u as Map)['role'] as String?;
      if (role == 'admin') {
        admins++;
      } else if (role == 'organizer') {
        organizers++;
      } else {
        participants++;
      }
    }

    int active = 0, pending = 0, completed = 0;
    for (final e in events) {
      final status = (e as Map)['status'] as String?;
      if (status == 'published') {
        active++;
      } else if (status == 'draft') {
        pending++;
      } else if (status == 'completed') {
        completed++;
      }
    }

    double revenue = 0;
    for (final b in bookings) {
      revenue += ((b as Map)['total_amount'] as num?)?.toDouble() ?? 0;
    }

    return {
      'totalUsers': users.length,
      'totalAdmins': admins,
      'totalOrganizers': organizers,
      'totalParticipants': participants,
      'totalEvents': events.length,
      'activeEvents': active,
      'pendingEvents': pending,
      'completedEvents': completed,
      'totalBookings': bookings.length,
      'totalTickets': tickets.length,
      'totalRevenue': revenue,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getUsers() async {
    final data = await supabase
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> updateUserRole(String userId, String newRole) async {
    await supabase.from('profiles').update({'role': newRole}).eq('id', userId);
  }

  @override
  Future<void> toggleUserActive(String userId) async {
    final current = await supabase
        .from('profiles')
        .select('is_active')
        .eq('id', userId)
        .single();
    final isActive = current['is_active'] as bool? ?? true;
    await supabase
        .from('profiles')
        .update({'is_active': !isActive}).eq('id', userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final data = await supabase
        .from('events')
        .select()
        .order('created_at', ascending: false);
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> approveEvent(String eventId,
      {bool approved = true, String? reason}) async {
    final updateData = <String, dynamic>{
      'status': approved ? 'published' : 'rejected',
    };
    if (reason != null) {
      updateData['rejection_reason'] = reason;
    }
    await supabase.from('events').update(updateData).eq('id', eventId);
  }

  @override
  Future<void> toggleEventFeatured(String eventId) async {
    final current = await supabase
        .from('events')
        .select('is_featured')
        .eq('id', eventId)
        .single();
    final isFeatured = current['is_featured'] as bool? ?? false;
    await supabase
        .from('events')
        .update({'is_featured': !isFeatured}).eq('id', eventId);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await supabase.from('events').delete().eq('id', eventId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final data = await supabase
        .from('bookings')
        .select()
        .order('created_at', ascending: false);
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllTickets() async {
    final data = await supabase
        .from('tickets')
        .select()
        .order('created_at', ascending: false);
    return data.cast<Map<String, dynamic>>();
  }
}
