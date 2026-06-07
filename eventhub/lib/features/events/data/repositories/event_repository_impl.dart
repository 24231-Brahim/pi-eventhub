import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/core/network/network_info.dart';
import 'package:eventhub/features/events/data/datasources/event_remote_datasource.dart';
import 'package:eventhub/features/events/data/models/event_model.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
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
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final data = await remoteDataSource.getEvents(
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
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final data = await remoteDataSource.getEventById(id);
      return Right(EventModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> createEvent(Event event) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
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
      final data = await remoteDataSource.createEvent(eventModel.toJson());
      return Right(EventModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> updateEvent(Event event) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
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
      final data = await remoteDataSource.updateEvent(eventModel.toJson());
      return Right(EventModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.deleteEvent(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
