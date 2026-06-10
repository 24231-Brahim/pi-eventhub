import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/data/datasources/event_supabase_datasource.dart';
import 'package:eventhub/features/events/data/models/event_invitation_model.dart';
import 'package:eventhub/features/events/data/models/event_model.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/entities/event_invitation.dart';
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
    String? organizerId,
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
        organizerId: organizerId,
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
        isFeatured: event.isFeatured,
        isPrivate: event.isPrivate,
        rejectionReason: event.rejectionReason,
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
        isFeatured: event.isFeatured,
        isPrivate: event.isPrivate,
        rejectionReason: event.rejectionReason,
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

  @override
  Future<Either<Failure, bool>> toggleFavorite(String eventId) async {
    try {
      final userId = supabase.auth.currentUser?.id ?? '';
      final isFavorited = await dataSource.toggleFavorite(eventId, userId);
      return Right(isFavorited);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getUserFavoriteIds() async {
    try {
      final userId = supabase.auth.currentUser?.id ?? '';
      final ids = await dataSource.getUserFavoriteIds(userId);
      return Right(ids);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EventInvitation>>> getInvitations(
      String eventId) async {
    try {
      final data = await dataSource.getInvitations(eventId);
      final invitations =
          data.map((e) => EventInvitationModel.fromJson(e)).toList();
      return Right(invitations);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventInvitation>> createInvitation(
      String eventId, String email, String name) async {
    try {
      final data = await dataSource.createInvitation({
        'eventId': eventId,
        'email': email,
        'name': name,
      });
      return Right(EventInvitationModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInvitation(String id) async {
    try {
      await dataSource.deleteInvitation(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createInvitationsBulk(
      String eventId, List<Map<String, String>> invitations) async {
    try {
      final data = invitations
          .map((inv) => {
                'eventId': eventId,
                'email': inv['email'] ?? '',
                'name': inv['name'] ?? '',
              })
          .toList();
      await dataSource.createInvitationsBulk(data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
