import 'package:eventhub/core/constants/api_constants.dart';
import 'package:eventhub/core/network/api_client.dart';

abstract class EventRemoteDataSource {
  Future<List<Map<String, dynamic>>> getEvents({
    int page = 0,
    int size = 20,
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    DateTime? date,
  });
  Future<Map<String, dynamic>> getEventById(String id);
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> event);
  Future<Map<String, dynamic>> updateEvent(Map<String, dynamic> event);
  Future<void> deleteEvent(String id);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final ApiClient apiClient;
  EventRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getEvents({
    int page = 0,
    int size = 20,
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    DateTime? date,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (category != null) queryParams['category'] = category;
    if (city != null) queryParams['city'] = city;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (date != null) queryParams['date'] = date.toIso8601String();

    final response = await apiClient.get(
      ApiConstants.events,
      queryParameters: queryParams,
    );
    final data = response.data as Map<String, dynamic>;
    return (data['content'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getEventById(String id) async {
    final response = await apiClient.get('${ApiConstants.events}/$id');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> event) async {
    final response = await apiClient.post(ApiConstants.events, data: event);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateEvent(Map<String, dynamic> event) async {
    final id = event['id'];
    final response =
        await apiClient.put('${ApiConstants.events}/$id', data: event);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> deleteEvent(String id) async {
    await apiClient.delete('${ApiConstants.events}/$id');
  }
}
