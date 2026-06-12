import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/bookings/domain/repositories/booking_repository.dart';

class ConfirmBookingUseCase {
  final BookingRepository repository;
  ConfirmBookingUseCase({required this.repository});

  Future<Either<Failure, void>> call(String bookingId) {
    return repository.confirmBooking(bookingId);
  }
}
