import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/core/utils/date_utils.dart' as app_date_utils;
import 'package:eventhub/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub/features/tickets/presentation/bloc/ticket_bloc.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/shared/widgets/empty_widget.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TicketBloc>().add(const GetUserTicketsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.obsidian,
        title: Text(l10n.myTickets),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/qr-scanner'),
          ),
        ],
      ),
      body: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          if (state is TicketLoading) {
            return const LoadingWidget();
          }
          if (state is TicketError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<TicketBloc>().add(const GetUserTicketsEvent()),
            );
          }
          if (state is UserTicketsLoaded) {
            if (state.tickets.isEmpty) {
              return EmptyWidget(message: l10n.noTickets);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.containerPadding),
              itemCount: state.tickets.length,
              itemBuilder: (context, index) {
                final ticket = state.tickets[index];
                return _TicketCard(
                  ticket: ticket,
                  l10n: l10n,
                  onTap: () => context.push('/qr-code', extra: ticket),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _TicketCard({
    required this.ticket,
    required this.l10n,
    required this.onTap,
  });

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
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.eventTitle ?? l10n.eventTicket,
                        style: AppTypography.headlineSm
                            .copyWith(color: AppColors.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.stackSm),
                      if (ticket.eventDate != null)
                        _IconLabel(
                          icon: Icons.calendar_today,
                          label: app_date_utils.DateUtils.formatFriendlyFromIso(
                              ticket.eventDate!),
                        ),
                      if (ticket.eventLocation != null) ...[
                        const SizedBox(height: 4),
                        _IconLabel(
                          icon: Icons.location_on,
                          label: ticket.eventLocation!,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.stackSm),
                      _TicketStatusBadge(status: ticket.status, l10n: l10n),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.stackMd),
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.vibrantGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.qr_code,
                      color: AppColors.vibrantGreen, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: AppTypography.labelMd.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketStatusBadge extends StatelessWidget {
  final TicketStatus status;
  final AppLocalizations l10n;
  const _TicketStatusBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status) {
      case TicketStatus.active:
        color = AppColors.vibrantGreen;
        label = l10n.activeStatus;
      case TicketStatus.used:
        color = AppColors.onSurfaceVariant;
        label = l10n.usedStatus;
      case TicketStatus.cancelled:
        color = AppColors.error;
        label = l10n.cancelledStatus;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: AppSpacing.base / 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelMd.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
