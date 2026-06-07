import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/auth/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(repository: mockRepository);
  });

  const tEmail = 'test@test.com';
  const tPassword = 'Password123';

  test('should login successfully', () async {
    when(() => mockRepository.login(tEmail, tPassword))
        .thenAnswer((_) async => Right(tUser));

    final result = await useCase(tEmail, tPassword);

    expect(result, Right(tUser));
    verify(() => mockRepository.login(tEmail, tPassword)).called(1);
  });

  test('should return failure when login fails', () async {
    when(() => mockRepository.login(tEmail, tPassword))
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(tEmail, tPassword);

    expect(result, Left(tFailure));
  });
}
