import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/profile/domain/entities/profile.dart';
import 'package:eventhub/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase({required this.repository});

  Future<Either<Failure, Profile>> call() {
    return repository.getProfile();
  }
}
