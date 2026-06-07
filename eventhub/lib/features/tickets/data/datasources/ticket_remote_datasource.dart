import 'package:eventhub/core/constants/api_constants.dart';
import 'package:eventhub/core/network/api_client.dart';

abstract class TicketRemoteDataSource {
  Future<List<Map<String, dynamic>>> getUserTickets();
  Future<Map<String, dynamic>> validateTicket(String qrData);
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final ApiClient apiClient;
  TicketRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getUserTickets() async {
    final response = await apiClient.get(ApiConstants.tickets);
    final data = response.data as Map<String, dynamic>;
    return (data['content'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> validateTicket(String qrData) async {
    final response =
        await apiClient.post('${ApiConstants.tickets}/validate', data: {
      'qrData': qrData,
    });
    return response.data as Map<String, dynamic>;
  }
}
