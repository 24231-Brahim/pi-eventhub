import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/bookings/domain/repositories/booking_repository.dart';

class CancelBookingUseCase {
  final BookingRepository repository;
  CancelBookingUseCase({required this.repository});

  Future<Either<Failure, void>> call(String bookingId) {
    return repository.cancelBooking(bookingId);
  }
}
