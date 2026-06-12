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
import 'package:eventhub/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:eventhub/shared/themes/app_theme.dart';
import 'package:eventhub/shared/services/local_storage_service.dart';
import 'package:eventhub/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    publishableKey: SupabaseConstants.anonKey,
  );

  await di.initDependencies();
  final themeNotifier = ThemeNotifier(storage: di.sl<LocalStorageService>());
  di.sl.registerLazySingleton<ThemeNotifier>(() => themeNotifier);
  runApp(EventHubApp(themeNotifier: themeNotifier));
}

class EventHubApp extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const EventHubApp({super.key, required this.themeNotifier});

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
    widget.themeNotifier.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _appRouter.dispose();
    widget.themeNotifier.removeListener(_onChanged);
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
        BlocProvider.value(value: di.sl<AdminBloc>()),
      ],
      child: MaterialApp.router(
        title: 'EventHub',
        debugShowCheckedModeBanner: false,
        routerConfig: _appRouter.router,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: widget.themeNotifier.themeMode,
        locale: widget.themeNotifier.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  final LocalStorageService storage;
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  ThemeNotifier({required this.storage}) {
    _load();
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void _load() {
    final savedTheme = storage.getString('theme_mode');
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.byName(savedTheme);
    }
    final savedLocale = storage.getString('locale');
    if (savedLocale != null && savedLocale.isNotEmpty) {
      _locale = Locale(savedLocale);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await storage.setString('theme_mode', mode.name);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    await storage.setString('locale', locale.languageCode);
  }
}
