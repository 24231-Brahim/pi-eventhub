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

Widget createTestWidget(AuthBloc authBloc) => MaterialApp(
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

  group('RegisterPage', () {
    testWidgets('renders registration form', (tester) async {
      await tester.pumpWidget(createTestWidget(authBloc));

      expect(find.text('Create Account'), findsNWidgets(2));
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Discover Events'), findsOneWidget);
      expect(find.text('Organize Events'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      await tester.pumpWidget(createTestWidget(authBloc));

      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('selects role when tapping role cards', (tester) async {
      await tester.pumpWidget(createTestWidget(authBloc));

      await tester.tap(find.text('Organize Events'));
      await tester.pump();

      expect(find.text('Organize Events'), findsOneWidget);
    });

    testWidgets('triggers register event on valid form', (tester) async {
      final completer = Completer<Either<Failure, User>>();
      when(() => mockRegisterUseCase.call(any(), any(), any(), any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(authBloc));

      final nameField = find.byType(TextFormField).at(0);
      final emailField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final confirmField = find.byType(TextFormField).at(3);

      await tester.enterText(nameField, 'Test User');
      await tester.enterText(emailField, 'test@test.com');
      await tester.enterText(passwordField, 'Password123');
      await tester.enterText(confirmField, 'Password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(authBloc.state, isA<AuthLoading>());

      completer.complete(const Right(tUser));
      await tester.pump();

      expect(authBloc.state, isA<Authenticated>());
    });
  });
}
