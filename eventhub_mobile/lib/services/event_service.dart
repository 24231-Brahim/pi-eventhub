import '../models/category.dart';
import '../models/event.dart';
import 'api_service.dart';

class EventService {
  Future<List<Event>> getAll() async {
    final response = await ApiService.get('/events');
    final list = ApiService.parseResponse(response) as List<dynamic>;
    return list.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Event> getById(int id) async {
    final response = await ApiService.get('/events/$id');
    return Event.fromJson(
        ApiService.parseResponse(response) as Map<String, dynamic>);
  }

  Future<Event> create(EventRequest request) async {
    final response = await ApiService.post('/events', request.toJson());
    return Event.fromJson(
        ApiService.parseResponse(response) as Map<String, dynamic>);
  }

  Future<Event> update(int id, EventRequest request) async {
    final response = await ApiService.put('/events/$id', request.toJson());
    return Event.fromJson(
        ApiService.parseResponse(response) as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final response = await ApiService.delete('/events/$id');
    ApiService.parseResponse(response);
  }

  Future<List<Category>> getCategories() async {
    final response = await ApiService.get('/categories');
    final list = ApiService.parseResponse(response) as List<dynamic>;
    return list
        .map((c) => Category.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<Category> createCategory(String name) async {
    final response = await ApiService.post('/categories', {'name': name});
    return Category.fromJson(
        ApiService.parseResponse(response) as Map<String, dynamic>);
  }
}
