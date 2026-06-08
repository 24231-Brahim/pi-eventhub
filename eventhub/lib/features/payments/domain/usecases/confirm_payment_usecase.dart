import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/payments/domain/entities/payment.dart';
import 'package:eventhub/features/payments/domain/repositories/payment_repository.dart';

class ConfirmPaymentUseCase {
  final PaymentRepository repository;
  ConfirmPaymentUseCase({required this.repository});

  Future<Either<Failure, Payment>> call(
      String paymentIntentId, String bookingId) {
    return repository.confirmPayment(paymentIntentId, bookingId);
  }
}
