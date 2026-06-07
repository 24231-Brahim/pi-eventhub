import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhub/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

Widget createTestWidget(AuthBloc authBloc) => MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (_) => authBloc,
        child: const ForgotPasswordPage(),
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

  testWidgets('renders forgot password form', (tester) async {
    await tester.pumpWidget(createTestWidget(authBloc));

    expect(find.text('Reset your password'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('shows dialog on success', (tester) async {
    final completer = Completer<Either<Failure, void>>();
    when(() => mockForgotPasswordUseCase.call(any()))
        .thenAnswer((_) => completer.future);

    await tester.pumpWidget(createTestWidget(authBloc));

    await tester.enterText(find.byType(TextFormField), 'test@test.com');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();

    expect(authBloc.state, isA<AuthLoading>());

    completer.complete(const Right(null));
    await tester.pump();

    expect(authBloc.state, isA<ForgotPasswordSuccess>());
  });
}
