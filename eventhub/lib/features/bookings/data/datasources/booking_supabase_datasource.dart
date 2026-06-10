import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookingSupabaseDataSource {
  Future<Map<String, dynamic>> createBooking(
      String eventId, int quantity, double amount, String userId);
  Future<List<Map<String, dynamic>>> getUserBookings(String userId);
  Future<void> cancelBooking(String bookingId);
}

class BookingSupabaseDataSourceImpl implements BookingSupabaseDataSource {
  final SupabaseClient supabase;

  BookingSupabaseDataSourceImpl({required this.supabase});

  @override
  Future<Map<String, dynamic>> createBooking(
      String eventId, int quantity, double amount, String userId) async {
    final response = await supabase.from('bookings').insert({
      'event_id': eventId,
      'user_id': userId,
      'quantity': quantity,
      'total_amount': amount,
      'status': 'pending',
    }).select().single();
    return _toCamelCase(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    final response = await supabase
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map((e) => _toCamelCase(e)).toList();
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }

  Map<String, dynamic> _toCamelCase(Map<String, dynamic> snake) {
    return {
      'id': snake['id'],
      'eventId': snake['event_id'],
      'userId': snake['user_id'],
      'eventTitle': snake['event_title'],
      'eventImageUrl': snake['event_image_url'],
      'eventDate': snake['event_date'],
      'eventLocation': snake['event_location'],
      'quantity': snake['quantity'],
      'totalAmount': snake['total_amount'],
      'status': snake['status'],
      'createdAt': snake['created_at'],
    };
  }
}
