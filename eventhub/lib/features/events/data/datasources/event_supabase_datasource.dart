import 'package:supabase_flutter/supabase_flutter.dart';

abstract class EventSupabaseDataSource {
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

class EventSupabaseDataSourceImpl implements EventSupabaseDataSource {
  final SupabaseClient supabase;

  EventSupabaseDataSourceImpl({required this.supabase});

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
    var query = supabase.from('events').select();

    if (category != null) {
      query = query.eq('category', category);
    }
    if (city != null) {
      query = query.eq('city', city);
    }
    if (minPrice != null) {
      query = query.gte('price', minPrice);
    }
    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
    }
    if (date != null) {
      query = query.gte('date', date.toIso8601String());
    }

    final paginated = query.order('date', ascending: true).range(
      page * size,
      (page + 1) * size - 1,
    );

    final response = await paginated;
    return response.map((e) => _toCamelCase(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> getEventById(String id) async {
    final response = await supabase
        .from('events')
        .select()
        .eq('id', id)
        .single();
    return _toCamelCase(response);
  }

  @override
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> event) async {
    final response = await supabase
        .from('events')
        .insert(_toSnakeCase(event))
        .select()
        .single();
    return _toCamelCase(response);
  }

  @override
  Future<Map<String, dynamic>> updateEvent(Map<String, dynamic> event) async {
    final id = event['id'];
    final data = Map<String, dynamic>.from(_toSnakeCase(event))
      ..remove('id')
      ..remove('created_at')
      ..['updated_at'] = DateTime.now().toIso8601String();
    final response = await supabase
        .from('events')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return _toCamelCase(response);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await supabase.from('events').delete().eq('id', id);
  }

  Map<String, dynamic> _toCamelCase(Map<String, dynamic> snake) {
    return {
      'id': snake['id'],
      'title': snake['title'],
      'description': snake['description'],
      'imageUrl': snake['image_url'],
      'date': snake['date'],
      'endDate': snake['end_date'],
      'location': snake['location'],
      'city': snake['city'],
      'latitude': snake['latitude'],
      'longitude': snake['longitude'],
      'price': snake['price'],
      'maxParticipants': snake['max_participants'],
      'currentParticipants': snake['current_participants'],
      'category': snake['category'],
      'status': snake['status'],
      'organizerId': snake['organizer_id'],
      'organizerName': snake['organizer_name'],
      'createdAt': snake['created_at'],
      'updatedAt': snake['updated_at'],
    };
  }

  Map<String, dynamic> _toSnakeCase(Map<String, dynamic> camel) {
    final result = <String, dynamic>{
      'title': camel['title'],
      'description': camel['description'],
      'image_url': camel['imageUrl'],
      'date': camel['date'],
      'end_date': camel['endDate'],
      'location': camel['location'],
      'city': camel['city'],
      'latitude': camel['latitude'],
      'longitude': camel['longitude'],
      'price': camel['price'],
      'max_participants': camel['maxParticipants'],
      'current_participants': camel['currentParticipants'],
      'category': camel['category'],
      'status': camel['status'],
      'organizer_id': camel['organizerId'],
      'organizer_name': camel['organizerName'],
      'created_at': camel['createdAt'],
      'updated_at': camel['updatedAt'],
    };
    final id = camel['id'];
    if (id != null && id is String && id.isNotEmpty) {
      result['id'] = id;
    }
    return result;
  }
}
