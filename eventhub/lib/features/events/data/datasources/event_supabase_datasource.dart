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
    String? organizerId,
  });
  Future<Map<String, dynamic>> getEventById(String id);
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> event);
  Future<Map<String, dynamic>> updateEvent(Map<String, dynamic> event);
  Future<void> deleteEvent(String id);
  Future<bool> toggleFavorite(String eventId, String userId);
  Future<List<String>> getUserFavoriteIds(String userId);

  Future<List<Map<String, dynamic>>> getInvitations(String eventId);
  Future<Map<String, dynamic>> createInvitation(Map<String, dynamic> invitation);
  Future<void> deleteInvitation(String id);
  Future<void> createInvitationsBulk(List<Map<String, dynamic>> invitations);
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
    String? organizerId,
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
    if (organizerId != null) {
      query = query.eq('organizer_id', organizerId);
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

  @override
  Future<bool> toggleFavorite(String eventId, String userId) async {
    final existing = await supabase
        .from('favorites')
        .select()
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .maybeSingle();
    if (existing != null) {
      await supabase
          .from('favorites')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', userId);
      return false;
    } else {
      await supabase.from('favorites').insert({
        'event_id': eventId,
        'user_id': userId,
      });
      return true;
    }
  }

  @override
  Future<List<String>> getUserFavoriteIds(String userId) async {
    final data = await supabase
        .from('favorites')
        .select('event_id')
        .eq('user_id', userId);
    return data.map((e) => e['event_id'] as String).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getInvitations(String eventId) async {
    final response = await supabase
        .from('event_invitations')
        .select()
        .eq('event_id', eventId)
        .order('created_at', ascending: true);
    return response.map((e) => _invitationToCamelCase(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> createInvitation(
      Map<String, dynamic> invitation) async {
    final response = await supabase
        .from('event_invitations')
        .insert(_invitationToSnakeCase(invitation))
        .select()
        .single();
    return _invitationToCamelCase(response);
  }

  @override
  Future<void> deleteInvitation(String id) async {
    await supabase.from('event_invitations').delete().eq('id', id);
  }

  @override
  Future<void> createInvitationsBulk(
      List<Map<String, dynamic>> invitations) async {
    final snakeCase = invitations.map(_invitationToSnakeCase).toList();
    await supabase.from('event_invitations').insert(snakeCase);
  }

  Map<String, dynamic> _invitationToCamelCase(Map<String, dynamic> snake) {
    return {
      'id': snake['id'],
      'eventId': snake['event_id'],
      'email': snake['email'],
      'name': snake['name'],
      'status': snake['status'],
      'createdAt': snake['created_at'],
    };
  }

  Map<String, dynamic> _invitationToSnakeCase(Map<String, dynamic> camel) {
    return {
      if (camel['id'] != null) 'id': camel['id'],
      'event_id': camel['eventId'],
      'email': camel['email'],
      if (camel['name'] != null) 'name': camel['name'],
      if (camel['status'] != null) 'status': camel['status'],
    };
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
      'isFeatured': snake['is_featured'],
      'isPrivate': snake['is_private'],
      'rejectionReason': snake['rejection_reason'],
      'createdAt': snake['created_at'],
      'updatedAt': snake['updated_at'],
    };
  }

  Map<String, dynamic> _toSnakeCase(Map<String, dynamic> camel) {
    final result = <String, dynamic>{};
    void addIfPresent(String key, dynamic value) {
      if (value != null) result[key] = value;
    }
    addIfPresent('title', camel['title']);
    addIfPresent('description', camel['description']);
    addIfPresent('image_url', camel['imageUrl']);
    addIfPresent('date', camel['date']);
    addIfPresent('end_date', camel['endDate']);
    addIfPresent('location', camel['location']);
    addIfPresent('city', camel['city']);
    addIfPresent('latitude', camel['latitude']);
    addIfPresent('longitude', camel['longitude']);
    addIfPresent('price', camel['price']);
    addIfPresent('max_participants', camel['maxParticipants']);
    addIfPresent('current_participants', camel['currentParticipants']);
    addIfPresent('category', camel['category']);
    addIfPresent('status', camel['status']);
    addIfPresent('organizer_id', camel['organizerId']);
    addIfPresent('organizer_name', camel['organizerName']);
    addIfPresent('is_featured', camel['isFeatured']);
    addIfPresent('is_private', camel['isPrivate']);
    addIfPresent('rejection_reason', camel['rejectionReason']);
    addIfPresent('created_at', camel['createdAt']);
    addIfPresent('updated_at', camel['updatedAt']);
    final id = camel['id'];
    if (id != null && id is String && id.isNotEmpty) {
      result['id'] = id;
    }
    return result;
  }
}
