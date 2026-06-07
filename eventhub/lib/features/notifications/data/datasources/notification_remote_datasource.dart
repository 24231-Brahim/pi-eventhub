import 'package:eventhub/core/constants/api_constants.dart';
import 'package:eventhub/core/network/api_client.dart';

abstract class NotificationRemoteDataSource {
  Future<List<Map<String, dynamic>>> getNotifications();
}

class NotificationRemoteDataSourceImpl
    implements NotificationRemoteDataSource {
  final ApiClient apiClient;
  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await apiClient.get(ApiConstants.notifications);
    final data = response.data as Map<String, dynamic>;
    return (data['content'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}
