import 'package:supabase_flutter/supabase_flutter.dart';

class TicketValidationException implements Exception {
  final String message;
  TicketValidationException(this.message);

  @override
  String toString() => message;
}

abstract class TicketSupabaseDataSource {
  Future<List<Map<String, dynamic>>> getUserTickets(String userId);
  Future<Map<String, dynamic>> validateTicket(String qrData, String currentUserId);
  Future<Map<String, dynamic>> createTicket({
    required String eventId,
    required String userId,
    required String bookingId,
    String? eventTitle,
    String? eventDate,
    String? eventLocation,
    required String qrCode,
  });
}

class TicketSupabaseDataSourceImpl implements TicketSupabaseDataSource {
  final SupabaseClient supabase;

  TicketSupabaseDataSourceImpl({required this.supabase});

  @override
  Future<List<Map<String, dynamic>>> getUserTickets(String userId) async {
    final response = await supabase
        .from('tickets')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map((e) => _toCamelCase(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> validateTicket(String qrData, String currentUserId) async {
    final ticket = await supabase
        .from('tickets')
        .select()
        .eq('qr_code', qrData)
        .single();

    final event = await supabase
        .from('events')
        .select('organizer_id')
        .eq('id', ticket['event_id'])
        .single()
        .timeout(const Duration(seconds: 5));

    if (event['organizer_id'] != currentUserId) {
      throw TicketValidationException(
        'Only the event organizer can validate tickets.',
      );
    }

    if (ticket['status'] == 'active') {
      final updated = await supabase
          .from('tickets')
          .update({'status': 'used'})
          .eq('id', ticket['id'])
          .select()
          .single();
      return _toCamelCase(updated);
    }

    return _toCamelCase(ticket);
  }

  @override
  Future<Map<String, dynamic>> createTicket({
    required String eventId,
    required String userId,
    required String bookingId,
    String? eventTitle,
    String? eventDate,
    String? eventLocation,
    required String qrCode,
  }) async {
    final response = await supabase.from('tickets').insert({
      'event_id': eventId,
      'user_id': userId,
      'booking_id': bookingId,
      'event_title': eventTitle,
      'event_date': eventDate,
      'event_location': eventLocation,
      'qr_code': qrCode,
      'status': 'active',
    }).select().single();
    return _toCamelCase(response);
  }

  Map<String, dynamic> _toCamelCase(Map<String, dynamic> snake) {
    return {
      'id': snake['id'],
      'eventId': snake['event_id'],
      'userId': snake['user_id'],
      'bookingId': snake['booking_id'],
      'eventTitle': snake['event_title'],
      'eventDate': snake['event_date'],
      'eventLocation': snake['event_location'],
      'qrCode': snake['qr_code'],
      'status': snake['status'],
      'createdAt': snake['created_at'],
    };
  }
}
