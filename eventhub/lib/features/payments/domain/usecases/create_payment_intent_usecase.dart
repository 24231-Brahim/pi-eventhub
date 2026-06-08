import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/payments/domain/repositories/payment_repository.dart';

class CreatePaymentIntentUseCase {
  final PaymentRepository repository;
  CreatePaymentIntentUseCase({required this.repository});

  Future<Either<Failure, String>> call(
      double amount, String currency, String bookingId) {
    return repository.createPaymentIntent(amount, currency, bookingId);
  }
}
