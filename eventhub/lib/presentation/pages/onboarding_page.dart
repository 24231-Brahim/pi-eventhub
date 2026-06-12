import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/services/local_storage_service.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';
import 'package:eventhub/core/di/injection_container.dart' as di;

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<_OnboardingContent> _buildPages(AppLocalizations l10n) => [
    _OnboardingContent(
      key: const ValueKey(0),
      icon: Icons.explore,
      title: l10n.browseEvents,
      description: l10n.browseEventsDesc,
    ),
    _OnboardingContent(
      key: const ValueKey(1),
      icon: Icons.confirmation_number,
      title: l10n.bookTickets,
      description: l10n.bookTicketsDesc,
    ),
    _OnboardingContent(
      key: const ValueKey(2),
      icon: Icons.share,
      title: l10n.enjoyShare,
      description: l10n.enjoyShareDesc,
    ),
  ];

  void _finishOnboarding() {
    di.sl<LocalStorageService>().setBool('onboarding_completed', true);
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _buildPages(l10n);
    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                    key: const ValueKey('onboarding_pages'),
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    children: pages,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.containerPadding,
                    vertical: AppSpacing.stackLg,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.base / 2,
                            ),
                            width: _currentPage == index ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.vibrantGreen
                                  : AppColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.stackLg),
                      ElevatedButton(
                        onPressed: () {
                          if (isLastPage) {
                            _finishOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(isLastPage ? l10n.getStarted : l10n.next),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: AppSpacing.containerPadding,
              right: AppSpacing.containerPadding,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  l10n.skip,
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingContent({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 256,
            height: 256,
            margin: const EdgeInsets.only(bottom: AppSpacing.stackLg * 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.vibrantGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.vibrantGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(icon, color: AppColors.vibrantGreen, size: 40),
              ),
            ),
          ),
          Text(
            title,
            style: AppTypography.headlineLgMobile.copyWith(
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.stackMd),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              description,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
