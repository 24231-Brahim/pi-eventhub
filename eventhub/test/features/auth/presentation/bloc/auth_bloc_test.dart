import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockForgotPasswordUseCase mockForgotPasswordUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockForgotPasswordUseCase = MockForgotPasswordUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
  });

  AuthBloc createBloc() => AuthBloc(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        forgotPasswordUseCase: mockForgotPasswordUseCase,
        logoutUseCase: mockLogoutUseCase,
      );

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when login succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockLoginUseCase.call('test@test.com', 'Password123'))
            .thenAnswer((_) async => const Right(tUser));
        bloc.add(const LoginEvent(email: 'test@test.com', password: 'Password123'));
      },
      expect: () => [isA<AuthLoading>(), isA<Authenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: createBloc,
      act: (bloc) {
        when(() => mockLoginUseCase.call('test@test.com', 'wrong'))
            .thenAnswer((_) async => const Left(tFailure));
        bloc.add(const LoginEvent(email: 'test@test.com', password: 'wrong'));
      },
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when register succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockRegisterUseCase.call('Test', 'test@test.com', 'Pass1234', 'participant'))
            .thenAnswer((_) async => const Right(tUser));
        bloc.add(const RegisterEvent(
          name: 'Test',
          email: 'test@test.com',
          password: 'Pass1234',
          role: 'participant',
        ));
      },
      expect: () => [isA<AuthLoading>(), isA<Authenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, ForgotPasswordSuccess] when forgot password succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockForgotPasswordUseCase.call('test@test.com'))
            .thenAnswer((_) async => const Right(null));
        bloc.add(const ForgotPasswordEvent(email: 'test@test.com'));
      },
      expect: () => [isA<AuthLoading>(), isA<ForgotPasswordSuccess>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when logout succeeds',
      build: createBloc,
      setUp: () {
        when(() => mockLogoutUseCase.call()).thenAnswer((_) async => const Right(null));
      },
      act: (bloc) => bloc.add(const LogoutEvent()),
      expect: () => [isA<AuthLoading>(), isA<Unauthenticated>()],
    );
  });
}
