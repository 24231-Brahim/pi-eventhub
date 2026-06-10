import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/features/auth/domain/entities/user.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhub/features/auth/presentation/pages/register_page.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

MaterialApp createApp(AuthBloc authBloc) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<AuthBloc>(
        create: (_) => authBloc,
        child: const RegisterPage(),
      ),
    );

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockForgotPasswordUseCase mockForgotPasswordUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late AuthBloc authBloc;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockForgotPasswordUseCase = MockForgotPasswordUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      forgotPasswordUseCase: mockForgotPasswordUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  testWidgets('Full register flow with participant role', (tester) async {
    final completer = Completer<Either<Failure, User>>();
    when(() => mockRegisterUseCase.call(
        'John Doe', 'john@test.com', 'StrongPass1', 'participant'))
        .thenAnswer((_) => completer.future);

    await tester.pumpWidget(createApp(authBloc));

    await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextFormField).at(1), 'john@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'StrongPass1');
    await tester.enterText(find.byType(TextFormField).at(3), 'StrongPass1');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();

    completer.complete(const Right(tUser));
    await tester.pump();
    await tester.pump();

    expect(authBloc.state, isA<Authenticated>());
  });

  testWidgets('Register flow with organizer role', (tester) async {
    final completer = Completer<Either<Failure, User>>();
    when(() => mockRegisterUseCase.call(
        'Org User', 'org@test.com', 'StrongPass1', 'organizer'))
        .thenAnswer((_) => completer.future);

    await tester.pumpWidget(createApp(authBloc));

    await tester.enterText(find.byType(TextFormField).at(0), 'Org User');
    await tester.enterText(find.byType(TextFormField).at(1), 'org@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'StrongPass1');
    await tester.enterText(find.byType(TextFormField).at(3), 'StrongPass1');

    await tester.tap(find.text('Organize Events'));
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();

    completer.complete(const Right(tUser));
    await tester.pump();
    await tester.pump();

    expect(authBloc.state, isA<Authenticated>());
  });

  testWidgets('Register shows error on failure', (tester) async {
    final completer = Completer<Either<Failure, User>>();
    when(() => mockRegisterUseCase.call(any(), any(), any(), any()))
        .thenAnswer((_) => completer.future);

    await tester.pumpWidget(createApp(authBloc));

    await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextFormField).at(1), 'existing@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'StrongPass1');
    await tester.enterText(find.byType(TextFormField).at(3), 'StrongPass1');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();

    completer.complete(
        const Left(ServerFailure(message: 'Email already exists')));
    await tester.pump();

    expect(authBloc.state, isA<AuthError>());
    expect((authBloc.state as AuthError).message, 'Email already exists');
  });
}
