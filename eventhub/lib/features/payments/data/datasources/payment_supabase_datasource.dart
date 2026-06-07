import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PaymentSupabaseDataSource {
  Future<Map<String, dynamic>> createPaymentIntent(
      double amount, String currency, String bookingId);
  Future<Map<String, dynamic>> confirmPayment(
      String paymentIntentId, String bookingId);
}

class PaymentSupabaseDataSourceImpl implements PaymentSupabaseDataSource {
  final SupabaseClient supabase;

  PaymentSupabaseDataSourceImpl({required this.supabase});

  @override
  Future<Map<String, dynamic>> createPaymentIntent(
      double amount, String currency, String bookingId) async {
    final response = await supabase.from('payments').insert({
      'booking_id': bookingId,
      'amount': amount,
      'currency': currency,
      'status': 'pending',
    }).select().single();
    return _toCamelCase(response);
  }

  @override
  Future<Map<String, dynamic>> confirmPayment(
      String paymentIntentId, String bookingId) async {
    final response = await supabase
        .from('payments')
        .update({'status': 'completed', 'stripe_payment_intent_id': paymentIntentId})
        .eq('booking_id', bookingId)
        .select()
        .single();
    return _toCamelCase(response);
  }

  Map<String, dynamic> _toCamelCase(Map<String, dynamic> snake) {
    return {
      'id': snake['id'],
      'bookingId': snake['booking_id'],
      'amount': snake['amount'],
      'currency': snake['currency'],
      'status': snake['status'],
      'stripePaymentIntentId': snake['stripe_payment_intent_id'],
      'createdAt': snake['created_at'],
    };
  }
}
