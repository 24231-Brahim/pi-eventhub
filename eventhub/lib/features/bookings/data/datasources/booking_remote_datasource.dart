import 'package:eventhub/core/constants/api_constants.dart';
import 'package:eventhub/core/network/api_client.dart';

abstract class BookingRemoteDataSource {
  Future<Map<String, dynamic>> createBooking(
      String eventId, int quantity, double amount);
  Future<List<Map<String, dynamic>>> getUserBookings();
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final ApiClient apiClient;
  BookingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> createBooking(
      String eventId, int quantity, double amount) async {
    final response = await apiClient.post(ApiConstants.bookings, data: {
      'eventId': eventId,
      'quantity': quantity,
      'amount': amount,
    });
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getUserBookings() async {
    final response = await apiClient.get(ApiConstants.bookings);
    final data = response.data as Map<String, dynamic>;
    return (data['content'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}
