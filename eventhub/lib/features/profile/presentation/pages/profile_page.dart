import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/features/auth/domain/entities/user.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhub/features/bookings/domain/entities/booking.dart';
import 'package:eventhub/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:eventhub/features/profile/domain/entities/profile.dart';
import 'package:eventhub/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const GetProfileEvent());
    context.read<BookingBloc>().add(const GetUserBookingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const LoadingWidget();
          }
          if (state is ProfileError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<ProfileBloc>().add(const GetProfileEvent()),
            );
          }
          if (state is ProfileLoaded || state is ProfileUpdated) {
            final profile = state is ProfileLoaded
                ? state.profile
                : (state as ProfileUpdated).profile;
            final authState = context.watch<AuthBloc>().state;
            final isAdmin = authState is Authenticated &&
                authState.user.role == UserRole.admin;
            final isOrganizer = authState is Authenticated &&
                authState.user.role == UserRole.organizer;
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _ProfileHeader(profile: profile),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.account,
                        style: AppTypography.sectionHeader
                            .copyWith(color: AppColors.onSurface),
                      ),
                      const SizedBox(height: AppSpacing.stackMd),
                      _ProfileTile(
                        icon: Icons.edit,
                        label: l10n.editProfile,
                        onTap: () => context.push('/edit-profile'),
                      ),
                      if (isAdmin)
                        _ProfileTile(
                          icon: Icons.admin_panel_settings,
                          label: l10n.adminPanel,
                          onTap: () => context.push('/admin'),
                        ),
                      if (isOrganizer) ...[
                        _ProfileTile(
                          icon: Icons.dashboard,
                          label: l10n.dashboard,
                          onTap: () => context.push('/organizer-dashboard'),
                        ),
                        _ProfileTile(
                          icon: Icons.add_circle_outline,
                          label: l10n.createEvent,
                          onTap: () => context.push('/create-event'),
                        ),
                      ],
                      _ProfileTile(
                        icon: Icons.logout,
                        label: l10n.logout,
                        isDestructive: true,
                        onTap: () =>
                            context.read<AuthBloc>().add(const LogoutEvent()),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const LoadingWidget();
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Profile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.stackLg,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.obsidian, AppColors.cardSurface],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: AppColors.vibrantGreen, width: 3),
              ),
            ),
            child: CircleAvatar(
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: AppTypography.headlineMd
                    .copyWith(color: AppColors.vibrantGreen),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Text(
            profile.name,
            style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.stackSm / 2),
          Text(
            profile.email,
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          const _StatsRow(),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        var attended = 0;
        var upcoming = 0;
        if (state is UserBookingsLoaded) {
          final now = DateTime.now();
          for (final booking in state.bookings) {
            if (booking.status == BookingStatus.cancelled) continue;
            final date = booking.eventDate;
            if (date == null) continue;
            if (date.isBefore(now)) {
              attended++;
            } else {
              upcoming++;
            }
          }
        }
        final points = attended * 100;
        return Row(
          children: [
            Expanded(
              child: _StatItem(value: '$attended', label: l10n.eventsAttended),
            ),
            const _StatDivider(),
            Expanded(
              child: _StatItem(value: '$upcoming', label: l10n.upcoming),
            ),
            const _StatDivider(),
            Expanded(
              child: _StatItem(value: '$points', label: l10n.points),
            ),
          ],
        );
      },
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.outlineVariant.withValues(alpha: 0.3),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineSm.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.stackSm / 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.onSurface;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.gutter),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.stackMd,
              vertical: AppSpacing.gutter,
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppSpacing.stackMd),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.labelLg.copyWith(color: color),
                  ),
                ),
                Icon(Icons.chevron_right, color: color.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
