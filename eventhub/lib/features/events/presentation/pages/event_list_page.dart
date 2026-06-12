import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/features/auth/domain/entities/user.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/features/events/presentation/widgets/event_card.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/shared/widgets/empty_widget.dart';
import 'package:eventhub/shared/widgets/fade_slide_in.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final _searchController = TextEditingController();
  EventCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(const GetEventsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(EventCategory? category) {
    setState(() => _selectedCategory = category);
    context.read<EventBloc>().add(GetEventsEvent(category: category?.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerPadding,
                AppSpacing.stackMd,
                AppSpacing.containerPadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GreetingHeader(subtitle: l10n.discoverEventsNearYou),
                  const _QuickActionsSection(),
                  const SizedBox(height: AppSpacing.stackLg),
                  _SearchField(
                    controller: _searchController,
                    hintText: l10n.searchEventsHint,
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  _CategoryChipsRow(
                    selected: _selectedCategory,
                    onSelected: _onCategorySelected,
                    allLabel: l10n.allEvents,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<EventBloc, EventState>(
                builder: (context, state) {
                  if (state is EventLoading) {
                    return const LoadingWidget();
                  }
                  if (state is EventError) {
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: () => context.read<EventBloc>().add(
                            GetEventsEvent(category: _selectedCategory?.name),
                          ),
                    );
                  }
                  if (state is EventsLoaded) {
                    final query = _searchQuery.toLowerCase();
                    final events = query.isEmpty
                        ? state.events
                        : state.events
                            .where((e) =>
                                e.title.toLowerCase().contains(query) ||
                                e.description.toLowerCase().contains(query) ||
                                (e.city?.toLowerCase().contains(query) ??
                                    false))
                            .toList();
                    if (events.isEmpty) {
                      return EmptyWidget(message: l10n.noEvents);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.containerPadding,
                        AppSpacing.stackSm,
                        AppSpacing.containerPadding,
                        AppSpacing.containerPadding,
                      ),
                      itemCount: events.length,
                      itemBuilder: (context, index) => FadeSlideIn(
                        delay: Duration(milliseconds: 60 * index.clamp(0, 8)),
                        child: EventCard(
                          event: events[index],
                          onTap: () => context.push(
                            '/event-details',
                            extra: events[index],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String subtitle;

  const _GreetingHeader({required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final name =
        authState is Authenticated ? authState.user.name.split(' ').first : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.isEmpty ? 'Hey there 👋' : 'Hey, $name 👋',
          style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: AppSpacing.stackSm),
        Text(
          subtitle,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.watch<AuthBloc>().state;
    final canManage = authState is Authenticated &&
        (authState.user.role == UserRole.organizer ||
            authState.user.role == UserRole.admin);
    if (!canManage) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.stackLg),
        Text(
          l10n.quickActions,
          style: AppTypography.sectionHeader.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_circle_outline,
                label: l10n.createEvent,
                onTap: () => context.push('/create-event'),
              ),
            ),
            const SizedBox(width: AppSpacing.gutter),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.list_alt,
                label: l10n.manageEvents,
                onTap: () => context.push('/manage-events'),
              ),
            ),
            const SizedBox(width: AppSpacing.gutter),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.qr_code_scanner,
                label: l10n.scanQR,
                onTap: () => context.push('/qr-scanner'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.stackMd,
            horizontal: AppSpacing.stackSm,
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.vibrantGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.vibrantGreen),
              ),
              const SizedBox(height: AppSpacing.stackSm),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurface,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.gutter,
          ),
        ),
      ),
    );
  }
}

class _CategoryChipsRow extends StatelessWidget {
  final EventCategory? selected;
  final ValueChanged<EventCategory?> onSelected;
  final String allLabel;

  const _CategoryChipsRow({
    required this.selected,
    required this.onSelected,
    required this.allLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CategoryChip(
            label: allLabel,
            icon: Icons.apps,
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          ...EventCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.only(left: AppSpacing.stackSm),
              child: _CategoryChip(
                label: _categoryLabel(category),
                icon: categoryIcon(category),
                selected: selected == category,
                onTap: () => onSelected(category),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _categoryLabel(EventCategory category) =>
    category.name[0].toUpperCase() + category.name.substring(1);

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.stackMd,
            vertical: AppSpacing.gutter,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.vibrantGreen : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: selected
                ? null
                : Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.obsidian : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.stackSm),
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  color: selected ? AppColors.obsidian : AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
