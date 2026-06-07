import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late ForgotPasswordUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ForgotPasswordUseCase(repository: mockRepository);
  });

  const tEmail = 'test@test.com';

  test('should call forgotPassword on repository', () async {
    when(() => mockRepository.forgotPassword(tEmail))
        .thenAnswer((_) async => const Right(null));

    final result = await useCase(tEmail);

    expect(result, const Right(null));
    verify(() => mockRepository.forgotPassword(tEmail)).called(1);
  });

  test('should return failure when forgotPassword fails', () async {
    when(() => mockRepository.forgotPassword(tEmail))
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(tEmail);

    expect(result, const Left(tFailure));
  });
}
