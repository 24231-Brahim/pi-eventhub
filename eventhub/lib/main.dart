import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventhub/core/constants/supabase_constants.dart';
import 'package:eventhub/core/di/injection_container.dart' as di;
import 'package:eventhub/core/router/app_router.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:eventhub/features/tickets/presentation/bloc/ticket_bloc.dart';
import 'package:eventhub/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:eventhub/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:eventhub/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:eventhub/shared/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.anonKey,
  );

  await di.initDependencies();
  runApp(const EventHubApp());
}

class EventHubApp extends StatefulWidget {
  const EventHubApp({super.key});

  @override
  State<EventHubApp> createState() => _EventHubAppState();
}

class _EventHubAppState extends State<EventHubApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    final authBloc = di.sl<AuthBloc>();
    authBloc.add(const CheckAuthEvent());
    _appRouter = AppRouter(authBloc: authBloc);
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: di.sl<AuthBloc>()),
        BlocProvider.value(value: di.sl<EventBloc>()),
        BlocProvider.value(value: di.sl<BookingBloc>()),
        BlocProvider.value(value: di.sl<TicketBloc>()),
        BlocProvider.value(value: di.sl<PaymentBloc>()),
        BlocProvider.value(value: di.sl<NotificationBloc>()),
        BlocProvider.value(value: di.sl<ProfileBloc>()),
      ],
      child: MaterialApp.router(
        title: 'EventHub',
        debugShowCheckedModeBanner: false,
        routerConfig: _appRouter.router,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('fr', 'FR'),
          Locale('ar', 'SA'),
        ],
      ),
    );
  }
}
