import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:eventhub_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/invitation_provider.dart';
import 'providers/language_provider.dart';
import 'views/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final langProvider = LanguageProvider();
  await langProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: langProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => InvitationProvider()),
      ],
      child: const EventHubApp(),
    ),
  );
}

class EventHubApp extends StatelessWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return MaterialApp(
      title: 'EventHub',
      debugShowCheckedModeBanner: false,

      // ── Theming ────────────────────────────────────────────────────────────
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0), // indigo
          secondary: const Color(0xFF7E57C2), // deep purple
          brightness: Brightness.light,
        ),
        fontFamily: 'Cairo',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(18))),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),

      // ── Localisation ───────────────────────────────────────────────────────
      locale: lang.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('ar'),
      ],

      // RTL support for Arabic
      builder: (context, child) {
        final isAr = lang.locale.languageCode == 'ar';
        return Directionality(
          textDirection:
              isAr ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },

      // ── Initial route ──────────────────────────────────────────────────────
      home: const LoginScreen(),
    );
  }
}
