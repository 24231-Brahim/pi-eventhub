import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/profile/domain/entities/profile.dart';
import 'package:eventhub/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase({required this.repository});

  Future<Either<Failure, Profile>> call(
      String name, String? phone, String? photoUrl) {
    return repository.updateProfile(name, phone, photoUrl);
  }
}
