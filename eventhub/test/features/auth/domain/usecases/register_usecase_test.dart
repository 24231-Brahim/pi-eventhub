import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/auth/domain/usecases/register_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late RegisterUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(repository: mockRepository);
  });

  const tName = 'Test User';
  const tEmail = 'test@test.com';
  const tPassword = 'Password123';
  const tRole = 'participant';

  test('should register successfully', () async {
    when(() => mockRepository.register(tName, tEmail, tPassword, tRole))
        .thenAnswer((_) async => Right(tUser));

    final result = await useCase(tName, tEmail, tPassword, tRole);

    expect(result, Right(tUser));
    verify(() => mockRepository.register(tName, tEmail, tPassword, tRole)).called(1);
  });

  test('should return failure when registration fails', () async {
    when(() => mockRepository.register(tName, tEmail, tPassword, tRole))
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(tName, tEmail, tPassword, tRole);

    expect(result, Left(tFailure));
  });
}
