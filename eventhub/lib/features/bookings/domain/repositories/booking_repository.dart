import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/bookings/domain/entities/booking.dart';

abstract class BookingRepository {
  Future<Either<Failure, Booking>> createBooking(String eventId, int quantity, double amount);
  Future<Either<Failure, List<Booking>>> getUserBookings();
  Future<Either<Failure, void>> cancelBooking(String bookingId);
}
