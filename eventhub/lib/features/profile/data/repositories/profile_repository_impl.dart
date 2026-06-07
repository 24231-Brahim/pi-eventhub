import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/profile/data/datasources/profile_supabase_datasource.dart';
import 'package:eventhub/features/profile/data/models/profile_model.dart';
import 'package:eventhub/features/profile/domain/entities/profile.dart';
import 'package:eventhub/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileSupabaseDataSource dataSource;
  final SupabaseClient supabase;

  ProfileRepositoryImpl({
    required this.dataSource,
    required this.supabase,
  });

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id ?? '';
      final data = await dataSource.getProfile(userId);
      return Right(ProfileModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(
      String name, String? phone, String? photoUrl) async {
    try {
      final userId = supabase.auth.currentUser?.id ?? '';
      final data =
          await dataSource.updateProfile(userId, name, phone, photoUrl);
      return Right(ProfileModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
