import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/bookings/data/datasources/booking_supabase_datasource.dart';
import 'package:eventhub/features/bookings/data/models/booking_model.dart';
import 'package:eventhub/features/bookings/domain/entities/booking.dart';
import 'package:eventhub/features/bookings/domain/repositories/booking_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingSupabaseDataSource dataSource;
  final SupabaseClient supabase;

  BookingRepositoryImpl({
    required this.dataSource,
    required this.supabase,
  });

  @override
  Future<Either<Failure, Booking>> createBooking(
      String eventId, int quantity, double amount) async {
    try {
      final userId = supabase.auth.currentUser?.id ?? '';
      final data =
          await dataSource.createBooking(eventId, quantity, amount, userId);
      return Right(BookingModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getUserBookings() async {
    try {
      final userId = supabase.auth.currentUser?.id ?? '';
      final data = await dataSource.getUserBookings(userId);
      final bookings = data.map((e) => BookingModel.fromJson(e)).toList();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    try {
      await dataSource.cancelBooking(bookingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
