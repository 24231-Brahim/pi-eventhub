import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/bookings/domain/entities/booking.dart';
import 'package:eventhub/features/bookings/domain/repositories/booking_repository.dart';

class GetUserBookingsUseCase {
  final BookingRepository repository;
  GetUserBookingsUseCase({required this.repository});

  Future<Either<Failure, List<Booking>>> call() {
    return repository.getUserBookings();
  }
}
