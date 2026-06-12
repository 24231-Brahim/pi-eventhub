import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';

/// Shows the "Booking Confirmed!" success modal matching the Vibrant Pulse
/// `event_details_booking` mockup: a blurred backdrop, a check icon, the
/// order summary and a "View Tickets" CTA.
Future<void> showBookingConfirmationModal(
  BuildContext context, {
  required String orderId,
  required String seatInfo,
  required VoidCallback onViewTickets,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8 * curved.value,
          sigmaY: 8 * curved.value,
        ),
        child: ColoredBox(
          color: AppColors.obsidian.withValues(alpha: 0.6 * curved.value),
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
              child: Center(
                child: _BookingConfirmationCard(
                  orderId: orderId,
                  seatInfo: seatInfo,
                  l10n: l10n,
                  onViewTickets: () {
                    Navigator.of(context).pop();
                    onViewTickets();
                  },
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _BookingConfirmationCard extends StatelessWidget {
  final String orderId;
  final String seatInfo;
  final AppLocalizations l10n;
  final VoidCallback onViewTickets;

  const _BookingConfirmationCard({
    required this.orderId,
    required this.seatInfo,
    required this.l10n,
    required this.onViewTickets,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 384),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.stackLg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.vibrantGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.vibrantGreen,
                  size: 48,
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              Text(
                l10n.bookingConfirmedTitle,
                style: AppTypography.headlineLgMobile.copyWith(
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.stackSm),
              Text(
                l10n.bookingConfirmedMessage,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.stackLg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.stackMd),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _InfoRow(label: l10n.orderId, value: orderId),
                    const SizedBox(height: AppSpacing.base),
                    _InfoRow(label: l10n.seats, value: seatInfo),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              ElevatedButton(
                onPressed: onViewTickets,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  foregroundColor: AppColors.onSurface,
                ),
                child: Text(l10n.viewTickets),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelMd.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
