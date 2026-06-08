import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TicketSupabaseDataSource {
  Future<List<Map<String, dynamic>>> getUserTickets(String userId);
  Future<Map<String, dynamic>> validateTicket(String qrData);
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
  Future<Map<String, dynamic>> validateTicket(String qrData) async {
    final ticket = await supabase
        .from('tickets')
        .select()
        .eq('qr_code', qrData)
        .single();

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
