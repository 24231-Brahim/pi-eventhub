import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.level1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'event-image-${event.id}',
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: event.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: event.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) =>
                                  _ImagePlaceholder(category: event.category),
                              errorWidget: (_, _, _) =>
                                  _ImagePlaceholder(category: event.category),
                            )
                          : _ImagePlaceholder(category: event.category),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.gutter,
                    left: AppSpacing.gutter,
                    child: _CategoryPill(category: event.category),
                  ),
                  Positioned(
                    top: AppSpacing.gutter,
                    right: AppSpacing.gutter,
                    child: _PriceBadge(event: event),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.vibrantGreen,
                        ),
                        const SizedBox(width: AppSpacing.stackSm),
                        Text(
                          DateFormat('MMM d, yyyy').format(event.date),
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.stackMd),
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.vibrantGreen,
                        ),
                        const SizedBox(width: AppSpacing.stackSm),
                        Expanded(
                          child: Text(
                            event.location,
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: AppSpacing.stackSm),
                        Text(
                          '${event.currentParticipants}/${event.maxParticipants}',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final EventCategory category;

  const _ImagePlaceholder({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerHigh,
            AppColors.vibrantGreen.withValues(alpha: 0.18),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        categoryIcon(category),
        size: 48,
        color: AppColors.vibrantGreen.withValues(alpha: 0.8),
      ),
    );
  }
}

/// Maps an [EventCategory] to a representative icon, used for category
/// chips and gradient image placeholders.
IconData categoryIcon(EventCategory category) {
  switch (category) {
    case EventCategory.conference:
      return Icons.groups;
    case EventCategory.concert:
      return Icons.music_note;
    case EventCategory.exhibition:
      return Icons.palette;
    case EventCategory.training:
      return Icons.school;
    case EventCategory.workshop:
      return Icons.build;
    case EventCategory.sports:
      return Icons.sports_soccer;
    case EventCategory.seminar:
      return Icons.campaign;
    case EventCategory.community:
      return Icons.diversity_3;
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

class _PriceBadge extends StatelessWidget {
  final Event event;
  const _PriceBadge({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: AppSpacing.base / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.obsidian.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        event.isFree ? 'FREE' : '${event.price.toStringAsFixed(2)} TND',
        style: AppTypography.labelMd.copyWith(
          color: AppColors.vibrantGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
