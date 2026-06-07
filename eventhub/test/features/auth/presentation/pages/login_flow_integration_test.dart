import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:eventhub/features/auth/domain/entities/user.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhub/features/auth/presentation/pages/login_page.dart';
import 'package:eventhub/features/auth/presentation/pages/register_page.dart';
import 'package:eventhub/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

Widget createApp(AuthBloc authBloc) => BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp(
        home: const LoginPage(),
        onGenerateRoute: (settings) {
          if (settings.name == '/register') {
            return MaterialPageRoute(
              builder: (_) => const RegisterPage(),
            );
          }
          if (settings.name == '/forgot-password') {
            return MaterialPageRoute(
              builder: (_) => const ForgotPasswordPage(),
            );
          }
          return null;
        },
      ),
    );

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockForgotPasswordUseCase mockForgotPasswordUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late AuthBloc authBloc;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockForgotPasswordUseCase = MockForgotPasswordUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      forgotPasswordUseCase: mockForgotPasswordUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  testWidgets('Full login flow: enter credentials and submit', (tester) async {
    final completer = Completer<Either<Failure, User>>();
    when(() => mockLoginUseCase.call('user@example.com', 'Password123'))
        .thenAnswer((_) => completer.future);

    await tester.pumpWidget(createApp(authBloc));

    await tester.enterText(
        find.byType(TextFormField).first, 'user@example.com');
    await tester.enterText(
        find.byType(TextFormField).last, 'Password123');

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(authBloc.state, isA<AuthLoading>());

    completer.complete(Right(tUser));
    await tester.pump();

    expect(authBloc.state, isA<Authenticated>());
  });

  testWidgets('Login flow: shows error on failure', (tester) async {
    final completer = Completer<Either<Failure, User>>();
    when(() => mockLoginUseCase.call('bad@email.com', 'wrong'))
        .thenAnswer((_) => completer.future);

    await tester.pumpWidget(createApp(authBloc));

    await tester.enterText(
        find.byType(TextFormField).first, 'bad@email.com');
    await tester.enterText(
        find.byType(TextFormField).last, 'wrong');

    await tester.tap(find.text('Login'));
    await tester.pump();

    completer.complete(
        const Left(ServerFailure(message: 'Invalid credentials')));
    await tester.pump();

    expect(authBloc.state, isA<AuthError>());
    expect((authBloc.state as AuthError).message, 'Invalid credentials');
  });

  testWidgets('Login to register navigation flow', (tester) async {
    await tester.pumpWidget(createApp(authBloc));

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsWidgets);
  });

  testWidgets('Login to forgot password navigation flow', (tester) async {
    await tester.pumpWidget(createApp(authBloc));

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset your password'), findsOneWidget);
  });
}
