import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/bookings/domain/entities/booking.dart';
import 'package:eventhub/features/bookings/domain/repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;
  CreateBookingUseCase({required this.repository});

  Future<Either<Failure, Booking>> call(
      String eventId, int quantity, double amount) {
    return repository.createBooking(eventId, quantity, amount);
  }
}
