import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/payments/domain/entities/payment.dart';

abstract class PaymentRepository {
  Future<Either<Failure, String>> createPaymentIntent(
      double amount, String currency);
  Future<Either<Failure, Payment>> confirmPayment(String paymentIntentId);
}
