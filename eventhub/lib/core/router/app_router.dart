import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhub/features/auth/presentation/pages/login_page.dart';
import 'package:eventhub/features/auth/presentation/pages/register_page.dart';
import 'package:eventhub/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/presentation/pages/event_list_page.dart';
import 'package:eventhub/features/events/presentation/pages/event_detail_page.dart';
import 'package:eventhub/features/events/presentation/pages/create_event_page.dart';
import 'package:eventhub/features/notifications/presentation/pages/notifications_page.dart';
import 'package:eventhub/features/profile/presentation/pages/profile_page.dart';
import 'package:eventhub/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:eventhub/features/tickets/presentation/pages/tickets_page.dart';
import 'package:eventhub/features/tickets/presentation/pages/qr_code_page.dart';
import 'package:eventhub/features/tickets/presentation/pages/qr_scanner_page.dart';
import 'package:eventhub/features/bookings/presentation/pages/my_bookings_page.dart';
import 'package:eventhub/features/payments/presentation/pages/booking_page.dart';
import 'package:eventhub/features/events/presentation/pages/organizer_dashboard_page.dart';
import 'package:eventhub/features/events/presentation/pages/manage_events_page.dart';
import 'package:eventhub/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:eventhub/features/admin/presentation/pages/admin_users_page.dart';
import 'package:eventhub/features/admin/presentation/pages/admin_events_page.dart';
import 'package:eventhub/features/admin/presentation/pages/admin_bookings_page.dart';
import 'package:eventhub/features/admin/presentation/pages/admin_tickets_page.dart';
import 'package:eventhub/features/admin/presentation/pages/admin_analytics_page.dart';
import 'package:eventhub/presentation/pages/splash_page.dart';
import 'package:eventhub/presentation/pages/onboarding_page.dart';
import 'package:eventhub/presentation/pages/settings_page.dart';
import 'package:eventhub/presentation/pages/home_shell.dart';

class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription _subscription;

  AuthNotifier(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final AuthBloc authBloc;
  late final AuthNotifier _authNotifier;

  AppRouter({required this.authBloc}) {
    _authNotifier = AuthNotifier(authBloc);
  }

  void dispose() {
    _authNotifier.dispose();
  }

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _authNotifier,
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is Authenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';

      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }
      if (isAdminRoute && isAuthenticated) {
        final user = authState.user;
        if (user.role.name != 'admin') {
          return '/';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const EventListPage(),
          ),
          GoRoute(
            path: '/tickets',
            builder: (context, state) => const TicketsPage(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/event-details',
        builder: (context, state) {
          final event = state.extra as Event;
          return EventDetailPage(event: event);
        },
      ),
      GoRoute(
        path: '/create-event',
        builder: (context, state) => const CreateEventPage(),
      ),
      GoRoute(
        path: '/edit-event',
        builder: (context, state) =>
            CreateEventPage(event: state.extra as dynamic),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) =>
            BookingPage(eventId: state.extra as String),
      ),
      GoRoute(
        path: '/my-bookings',
        builder: (context, state) => const MyBookingsPage(),
      ),
      GoRoute(
        path: '/qr-code',
        builder: (context, state) {
          final ticket = state.extra as dynamic;
          return QrCodePage(ticket: ticket);
        },
      ),
      GoRoute(
        path: '/qr-scanner',
        builder: (context, state) => const QrScannerPage(),
      ),
      GoRoute(
        path: '/organizer-dashboard',
        builder: (context, state) => const OrganizerDashboardPage(),
      ),
      GoRoute(
        path: '/manage-events',
        builder: (context, state) => const ManageEventsPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersPage(),
      ),
      GoRoute(
        path: '/admin/events',
        builder: (context, state) => const AdminEventsPage(),
      ),
      GoRoute(
        path: '/admin/bookings',
        builder: (context, state) => const AdminBookingsPage(),
      ),
      GoRoute(
        path: '/admin/tickets',
        builder: (context, state) => const AdminTicketsPage(),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AdminAnalyticsPage(),
      ),
    ],
  );
}
