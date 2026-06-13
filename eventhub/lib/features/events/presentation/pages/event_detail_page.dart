import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:eventhub/core/di/injection_container.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';
import 'package:eventhub/shared/widgets/fade_slide_in.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;
  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late Event _event;
  bool _isFavorite = false;
  bool _favoritesLoaded = false;
  bool _isInvitedGuest = false;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    context.read<EventBloc>().add(GetEventByIdEvent(id: _event.id));
    context.read<EventBloc>().add(const GetUserFavoriteIdsEvent());
    if (_event.isPrivate) {
      _checkInvitedGuest();
    }
  }

  Future<void> _checkInvitedGuest() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;
    final email = authState.user.email.toLowerCase();
    final result = await sl<EventRepository>().getInvitations(_event.id);
    if (!mounted) return;
    result.fold(
      (failure) => null,
      (invitations) => setState(() {
        _isInvitedGuest =
            invitations.any((inv) => inv.email.toLowerCase() == email);
      }),
    );
  }

  void _toggleFavorite() {
    context.read<EventBloc>().add(ToggleFavoriteEvent(eventId: _event.id));
    setState(() => _isFavorite = !_isFavorite);
  }

  bool _canBook(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return false;
    if (_event.status != EventStatus.published) return false;
    if (_event.isPast) return false;
    if (_event.isFull) return false;
    if (_event.organizerId == authState.user.id) return false;
    if (_event.isPrivate && !_isInvitedGuest) return false;
    return true;
  }

  void _share(AppLocalizations l10n) {
    final text = [
      _event.title,
      '',
      _event.description,
      '',
      DateFormat('EEEE, MMM d, yyyy HH:mm').format(_event.date),
      '${_event.location}${_event.city != null ? ', ${_event.city}' : ''}',
      _event.isFree ? l10n.free : '${_event.price.toStringAsFixed(2)} TND',
      '',
      l10n.discoverAndBook,
    ].join('\n');
    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canBook = _canBook(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocListener<EventBloc, EventState>(
        listenWhen: (_, state) =>
            state is EventDetailLoaded ||
            state is FavoriteToggled ||
            state is FavoriteIdsLoadedState ||
            state is EventError,
        listener: (context, state) {
          if (state is EventDetailLoaded) {
            setState(() => _event = state.event);
          } else if (state is FavoriteToggled) {
            setState(() => _isFavorite = state.isFavorite);
          } else if (state is FavoriteIdsLoadedState) {
            setState(() {
              _isFavorite = state.ids.contains(_event.id);
              _favoritesLoaded = true;
            });
          } else if (state is EventError && _event.id == widget.event.id) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Stack(
          children: [
            _EventDetailContent(
              event: _event,
              l10n: l10n,
              reserveBottomBar: canBook,
            ),
            _FloatingTopBar(
              onBack: () => Navigator.of(context).maybePop(),
              onShare: () => _share(l10n),
              showFavorite: _favoritesLoaded,
              isFavorite: _isFavorite,
              onFavoriteToggle: _toggleFavorite,
            ),
            if (canBook)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _StickyBookBar(
                  event: _event,
                  l10n: l10n,
                  onBook: () => context.push('/booking', extra: _event.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EventDetailContent extends StatelessWidget {
  final Event event;
  final AppLocalizations l10n;
  final bool reserveBottomBar;

  const _EventDetailContent({
    required this.event,
    required this.l10n,
    required this.reserveBottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroSection(event: event),
          _ContentCard(event: event, l10n: l10n),
          SizedBox(height: reserveBottomBar ? 96 : AppSpacing.stackLg),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final Event event;
  const _HeroSection({required this.event});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'event-image-${event.id}',
            child: event.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: event.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.surfaceContainer),
                    errorWidget: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.surface.withValues(alpha: 0.3),
                  AppColors.surface,
                ],
                stops: const [0.4, 0.75, 1.0],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.containerPadding,
            right: AppSpacing.containerPadding,
            bottom: AppSpacing.stackLg,
            child: FadeSlideIn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CategoryPill(category: event.category),
                  const SizedBox(height: AppSpacing.stackSm),
                  Text(
                    event.title,
                    style: AppTypography.headlineLg.copyWith(
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 16,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceContainer,
      alignment: Alignment.center,
      child: const Icon(
        Icons.event,
        size: 80,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final EventCategory category;
  const _CategoryPill({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: AppSpacing.base / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.vibrantGreen,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        category.name.toUpperCase(),
        style: AppTypography.labelMd.copyWith(
          color: AppColors.obsidian,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final Event event;
  final AppLocalizations l10n;

  const _ContentCard({required this.event, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.containerPadding,
          AppSpacing.stackLg,
          AppSpacing.containerPadding,
          AppSpacing.stackLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: _PriceRow(event: event, l10n: l10n),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            FadeSlideIn(
              delay: const Duration(milliseconds: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoTile(
                    icon: Icons.calendar_today,
                    title: DateFormat('EEEE, MMM d, yyyy').format(event.date),
                    subtitle: event.endDate != null
                        ? '${DateFormat('HH:mm').format(event.date)} - ${DateFormat('HH:mm').format(event.endDate!)}'
                        : DateFormat('HH:mm').format(event.date),
                  ),
                  _InfoTile(
                    icon: Icons.location_on,
                    title: event.location,
                    subtitle: event.city,
                  ),
                  _InfoTile(
                    icon: Icons.people,
                    title:
                        '${event.currentParticipants}/${event.maxParticipants} ${l10n.participants}',
                  ),
                  if (event.organizerName != null)
                    _InfoTile(
                      icon: Icons.person,
                      title: event.organizerName!,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.about,
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  Text(
                    event.description,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
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

class _PriceRow extends StatelessWidget {
  final Event event;
  final AppLocalizations l10n;
  const _PriceRow({required this.event, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: AppSpacing.base,
          ),
          decoration: BoxDecoration(
            color: AppColors.vibrantGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.confirmation_number,
                color: AppColors.vibrantGreen,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.stackSm),
              Text(
                event.isFree ? l10n.free : '${event.price.toStringAsFixed(2)} TND',
                style: AppTypography.labelLg.copyWith(
                  color: AppColors.vibrantGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (event.isFeatured)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.gutter,
              vertical: AppSpacing.base,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: AppColors.vibrantGreen, size: 16),
                const SizedBox(width: AppSpacing.stackSm),
                Text(
                  'Featured',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _InfoTile({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.vibrantGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.vibrantGreen, size: 20),
          ),
          const SizedBox(width: AppSpacing.gutter),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onShare;
  final bool showFavorite;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const _FloatingTopBar({
    required this.onBack,
    required this.onShare,
    required this.showFavorite,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
            vertical: AppSpacing.stackSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _GlassIconButton(icon: Icons.arrow_back, onTap: onBack),
              Row(
                children: [
                  _GlassIconButton(icon: Icons.share, onTap: onShare),
                  if (showFavorite) ...[
                    const SizedBox(width: AppSpacing.base),
                    _GlassIconButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      iconColor:
                          isFavorite ? AppColors.vibrantGreen : Colors.white,
                      onTap: onFavoriteToggle,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    this.iconColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: AppColors.surfaceContainer.withValues(alpha: 0.5),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickyBookBar extends StatelessWidget {
  final Event event;
  final AppLocalizations l10n;
  final VoidCallback onBook;

  const _StickyBookBar({
    required this.event,
    required this.l10n,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.containerPadding,
            AppSpacing.stackMd,
            AppSpacing.containerPadding,
            AppSpacing.stackMd,
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sell_outlined,
                      color: AppColors.vibrantGreen,
                      size: 18,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.isFree
                          ? l10n.free
                          : '${event.price.toStringAsFixed(2)} TND',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.vibrantGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.stackLg),
                Expanded(
                  child: _GradientButton(label: l10n.bookNow, onTap: onBook),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.vibrantGreen, AppColors.primaryAccent],
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [
              BoxShadow(
                color: AppColors.vibrantGreen.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTypography.labelLg.copyWith(
              color: AppColors.obsidian,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
