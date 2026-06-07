import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('AuthRepositoryImpl', () {
    const tEmail = 'test@test.com';
    const tPassword = 'Password123';
    const tName = 'Test';
    const tRole = 'participant';

    final tUserJson = {
      'user': {
        'id': '1',
        'email': 'test@test.com',
        'name': 'Test',
        'role': 'participant',
      },
      'token': 'jwt-token',
      'refreshToken': 'refresh-token',
    };

    setUp(() {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    group('login', () {
      test('should return User on successful login', () async {
        when(() => mockDataSource.login(tEmail, tPassword))
            .thenAnswer((_) async => tUserJson);

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

      test('should return NetworkFailure when no connection', () async {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.login(tEmail, tPassword);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected Left'),
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
            .thenAnswer((_) async => tUserJson);

        final result =
            await repository.register(tName, tEmail, tPassword, tRole);

        expect(result.isRight(), true);
      });

      test('should return NetworkFailure when no connection', () async {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        final result =
            await repository.register(tName, tEmail, tPassword, tRole);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected Left'),
        );
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
