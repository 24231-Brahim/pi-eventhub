import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;
  ForgotPasswordUseCase({required this.repository});

  Future<Either<Failure, void>> call(String email) {
    return repository.forgotPassword(email);
  }
}
