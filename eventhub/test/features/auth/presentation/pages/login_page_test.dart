import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/features/auth/domain/entities/user.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhub/features/auth/presentation/pages/login_page.dart';
import 'package:eventhub/features/auth/presentation/pages/register_page.dart';
import 'package:eventhub/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

Widget createTestWidget(AuthBloc authBloc) {
  final goRouter = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordPage(),
      ),
    ],
  );
  return BlocProvider<AuthBloc>.value(
    value: authBloc,
    child: MaterialApp.router(
      routerConfig: goRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

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

  group('LoginPage', () {
    testWidgets('renders login form elements', (tester) async {
      await tester.pumpWidget(createTestWidget(authBloc));

      expect(find.text('EventHub'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('shows validation error for empty fields', (tester) async {
      await tester.pumpWidget(createTestWidget(authBloc));

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('emits loading state when logging in', (tester) async {
      final completer = Completer<Either<Failure, User>>();
      when(() => mockLoginUseCase.call(any(), any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(authBloc));

      await tester.enterText(
          find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(
          find.byType(TextFormField).last, 'Password123');
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(authBloc.state, isA<AuthLoading>());

      completer.complete(const Right(tUser));
      await tester.pump();

      expect(authBloc.state, isA<Authenticated>());
    });

    testWidgets('navigates to register page', (tester) async {
      await tester.pumpWidget(createTestWidget(authBloc));

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('navigates to forgot password page', (tester) async {
      await tester.pumpWidget(createTestWidget(authBloc));

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Reset your password'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(createTestWidget(authBloc));

      final visibilityButton = find.byIcon(Icons.visibility_off);
      expect(visibilityButton, findsOneWidget);

      await tester.tap(visibilityButton);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
