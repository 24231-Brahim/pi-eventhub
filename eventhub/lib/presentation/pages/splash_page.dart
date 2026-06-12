import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/services/local_storage_service.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_typography.dart';
import 'package:eventhub/core/di/injection_container.dart' as di;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat(reverse: true);
    _navigate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final storage = di.sl<LocalStorageService>();
    final onboardingDone = storage.getBool('onboarding_completed') ?? false;

    if (onboardingDone) {
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final t = _pulseController.value;
                final scale = 1.0 + (0.05 * t);
                final opacity = 1.0 - (0.2 * t);
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.vibrantGreen.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              l10n.appName,
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.vibrantGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.discoverAndBook,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
