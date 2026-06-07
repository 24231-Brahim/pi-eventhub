import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:eventhub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthSupabaseDataSource mockDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAuthSupabaseDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockDataSource,
    );
  });

  group('AuthRepositoryImpl', () {
    const tEmail = 'test@test.com';
    const tPassword = 'Password123';
    const tName = 'Test';
    const tRole = 'participant';

    setUp(() {});

    group('login', () {
      test('should return User on successful login', () async {
        when(() => mockDataSource.login(tEmail, tPassword)).thenAnswer(
          (_) async => AuthResponse(
            id: '1',
            email: tEmail,
            name: 'Test',
            role: 'participant',
            accessToken: 'token',
            refreshToken: 'refresh',
          ),
        );

        final result = await repository.login(tEmail, tPassword);

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (user) {
            expect(user.email, tEmail);
            expect(user.name, 'Test');
          },
        );
      });

      test('should return ServerFailure on exception', () async {
        when(() => mockDataSource.login(tEmail, tPassword))
            .thenThrow(Exception('API error'));

        final result = await repository.login(tEmail, tPassword);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('register', () {
      test('should return User on successful registration', () async {
        when(() => mockDataSource.register(tName, tEmail, tPassword, tRole))
            .thenAnswer(
          (_) async => AuthResponse(
            id: '1',
            email: tEmail,
            name: tName,
            role: tRole,
            accessToken: 'token',
            refreshToken: 'refresh',
          ),
        );

        final result =
            await repository.register(tName, tEmail, tPassword, tRole);

        expect(result.isRight(), true);
      });
    });

    group('forgotPassword', () {
      test('should complete successfully', () async {
        when(() => mockDataSource.forgotPassword(tEmail))
            .thenAnswer((_) async => {});

        final result = await repository.forgotPassword(tEmail);

        expect(result, const Right(null));
      });
    });

    group('logout', () {
      test('should complete successfully', () async {
        when(() => mockDataSource.logout()).thenAnswer((_) async => {});

        final result = await repository.logout();

        expect(result, const Right(null));
      });
    });
  });
}
