import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  List<Event> _events = [];
  List<Category> _categories = [];
  bool _loading = false;
  String? _error;

  List<Event> get events => _events;
  List<Category> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadEvents() async {
    _setLoading(true);
    try {
      _events = await _eventService.getAll();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _eventService.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> createEvent(EventRequest request) async {
    _setLoading(true);
    try {
      final newEvent = await _eventService.create(request);
      _events = [newEvent, ..._events];
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEvent(int id, EventRequest request) async {
    _setLoading(true);
    try {
      final updated = await _eventService.update(id, request);
      final idx = _events.indexWhere((e) => e.id == id);
      if (idx != -1) _events[idx] = updated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteEvent(int id) async {
    _setLoading(true);
    try {
      await _eventService.delete(id);
      _events.removeWhere((e) => e.id == id);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
