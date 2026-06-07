import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/data/datasources/event_supabase_datasource.dart';
import 'package:eventhub/features/events/data/models/event_model.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventRepositoryImpl implements EventRepository {
  final EventSupabaseDataSource dataSource;
  final SupabaseClient supabase;

  EventRepositoryImpl({
    required this.dataSource,
    required this.supabase,
  });

  @override
  Future<Either<Failure, List<Event>>> getEvents({
    int page = 0,
    int size = 20,
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    DateTime? date,
  }) async {
    try {
      final data = await dataSource.getEvents(
        page: page,
        size: size,
        category: category,
        city: city,
        minPrice: minPrice,
        maxPrice: maxPrice,
        date: date,
      );
      final events = data.map((e) => EventModel.fromJson(e)).toList();
      return Right(events);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventById(String id) async {
    try {
      final data = await dataSource.getEventById(id);
      return Right(EventModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> createEvent(Event event) async {
    try {
      final userId = supabase.auth.currentUser?.id ?? '';
      final eventModel = EventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        imageUrl: event.imageUrl,
        date: event.date,
        endDate: event.endDate,
        location: event.location,
        city: event.city,
        latitude: event.latitude,
        longitude: event.longitude,
        price: event.price,
        maxParticipants: event.maxParticipants,
        currentParticipants: event.currentParticipants,
        category: event.category,
        status: event.status,
        organizerId: userId,
        organizerName: event.organizerName,
        createdAt: event.createdAt,
        updatedAt: event.updatedAt,
      );
      final data = await dataSource.createEvent(eventModel.toJson());
      return Right(EventModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> updateEvent(Event event) async {
    try {
      final eventModel = EventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        imageUrl: event.imageUrl,
        date: event.date,
        endDate: event.endDate,
        location: event.location,
        city: event.city,
        latitude: event.latitude,
        longitude: event.longitude,
        price: event.price,
        maxParticipants: event.maxParticipants,
        currentParticipants: event.currentParticipants,
        category: event.category,
        status: event.status,
        organizerId: event.organizerId,
        organizerName: event.organizerName,
        createdAt: event.createdAt,
        updatedAt: event.updatedAt,
      );
      final data = await dataSource.updateEvent(eventModel.toJson());
      return Right(EventModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String id) async {
    try {
      await dataSource.deleteEvent(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
