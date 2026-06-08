import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/services/local_storage_service.dart';
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
      icon: Icons.event,
      title: l10n.discoverEvents,
      description: l10n.discoverEventsDesc,
    ),
    _OnboardingContent(
      key: const ValueKey(1),
      icon: Icons.book_online,
      title: l10n.bookTickets,
      description: l10n.bookTicketsDesc,
    ),
    _OnboardingContent(
      key: const ValueKey(2),
      icon: Icons.qr_code_scanner,
      title: l10n.easyCheckin,
      description: l10n.easyCheckinDesc,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _buildPages(l10n);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ClipRect(
                child: PageView(
                  key: const ValueKey('onboarding_pages'),
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  children: pages,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      di.sl<LocalStorageService>()
                          .setBool('onboarding_completed', true);
                      context.go('/login');
                    },
                    child: Text(l10n.skip),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == pages.length - 1) {
                        di.sl<LocalStorageService>()
                            .setBool('onboarding_completed', true);
                        context.go('/login');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == pages.length - 1 ? l10n.getStarted : l10n.next,
                    ),
                  ),
                ],
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
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 48),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
