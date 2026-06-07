import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/payments/data/datasources/payment_supabase_datasource.dart';
import 'package:eventhub/features/payments/data/models/payment_model.dart';
import 'package:eventhub/features/payments/domain/entities/payment.dart';
import 'package:eventhub/features/payments/domain/repositories/payment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentSupabaseDataSource dataSource;
  final SupabaseClient supabase;

  PaymentRepositoryImpl({
    required this.dataSource,
    required this.supabase,
  });

  @override
  Future<Either<Failure, String>> createPaymentIntent(
      double amount, String currency) async {
    try {
      final bookingId = ''; // In a real flow, this comes from creating a booking first
      final data =
          await dataSource.createPaymentIntent(amount, currency, bookingId);
      final payment = PaymentModel.fromJson(data);
      return Right(payment.id);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payment>> confirmPayment(
      String paymentIntentId) async {
    try {
      final bookingId = ''; // In a real flow, this comes from the booking
      final data =
          await dataSource.confirmPayment(paymentIntentId, bookingId);
      return Right(PaymentModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
