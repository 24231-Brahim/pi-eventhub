import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/entities/event_invitation.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/shared/widgets/empty_widget.dart';

class EventInvitationsPage extends StatefulWidget {
  final Event event;
  const EventInvitationsPage({super.key, required this.event});

  @override
  State<EventInvitationsPage> createState() => _EventInvitationsPageState();
}

class _EventInvitationsPageState extends State<EventInvitationsPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _loadInvitations() {
    context
        .read<EventBloc>()
        .add(GetInvitationsEvent(eventId: widget.event.id));
  }

  void _sendInvite() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    context.read<EventBloc>().add(CreateInvitationEvent(
          eventId: widget.event.id,
          email: email,
          name: _nameController.text.trim(),
        ));
    _emailController.clear();
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(l10n.guestInvitations),
        backgroundColor: AppColors.obsidian,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.containerPadding),
            child: _InviteForm(
              emailController: _emailController,
              nameController: _nameController,
              onSend: _sendInvite,
            ),
          ),
          Expanded(
            child: BlocConsumer<EventBloc, EventState>(
              listener: (context, state) {
                if (state is InvitationActionError) {
                  final message = state.message == 'This person is already invited'
                      ? l10n.alreadyInvited
                      : state.message;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is EventLoading) {
                  return const LoadingWidget();
                }
                if (state is EventError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: _loadInvitations,
                  );
                }
                List<EventInvitation>? invitations;
                if (state is InvitationsLoaded) {
                  invitations = state.invitations;
                } else if (state is InvitationActionError) {
                  invitations = state.invitations;
                }
                if (invitations != null) {
                  if (invitations.isEmpty) {
                    return EmptyWidget(
                      message: l10n.noInvitations,
                      icon: Icons.mail_outline,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.containerPadding,
                      0,
                      AppSpacing.containerPadding,
                      AppSpacing.containerPadding,
                    ),
                    itemCount: invitations.length,
                    itemBuilder: (context, index) {
                      final invitation = invitations![index];
                      return _InvitationCard(
                        invitation: invitation,
                        onDelete: () => context.read<EventBloc>().add(
                              DeleteInvitationEvent(
                                id: invitation.id,
                                eventId: widget.event.id,
                              ),
                            ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController nameController;
  final VoidCallback onSend;

  const _InviteForm({
    required this.emailController,
    required this.nameController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.inviteGuests,
            style: AppTypography.sectionHeader
                .copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          _InviteTextField(
            controller: emailController,
            hintText: l10n.emailHint,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.stackSm),
          _InviteTextField(
            controller: nameController,
            hintText: l10n.nameHint,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: AppSpacing.stackMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vibrantGreen,
                foregroundColor: AppColors.obsidian,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.gutter),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              icon: const Icon(Icons.send),
              label: Text(
                l10n.sendInvite,
                style: AppTypography.labelLg
                    .copyWith(color: AppColors.obsidian),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;

  const _InviteTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
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

class _InvitationCard extends StatelessWidget {
  final EventInvitation invitation;
  final VoidCallback onDelete;

  const _InvitationCard({required this.invitation, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.gutter),
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.surfaceContainerHigh,
            child: Icon(Icons.person_outline,
                color: AppColors.vibrantGreen),
          ),
          const SizedBox(width: AppSpacing.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.email,
                  style: AppTypography.labelLg
                      .copyWith(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (invitation.name.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    invitation.name,
                    style: AppTypography.bodyMd
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.stackSm),
          _InvitationStatusBadge(status: invitation.status),
          IconButton(
            icon: const Icon(Icons.close,
                size: 18, color: AppColors.onSurfaceVariant),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _InvitationStatusBadge extends StatelessWidget {
  final InvitationStatus status;
  const _InvitationStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color color;
    final String label;
    switch (status) {
      case InvitationStatus.accepted:
        color = AppColors.vibrantGreen;
        label = l10n.acceptedStatus;
      case InvitationStatus.pending:
        color = AppColors.warning;
        label = l10n.pendingStatus;
      case InvitationStatus.declined:
        color = AppColors.error;
        label = l10n.declinedStatus;
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
