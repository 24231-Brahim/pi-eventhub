import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventhub_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/invitation_provider.dart';
import '../scanner/qr_scanner_screen.dart';
import 'event_form_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final ep = context.watch<EventProvider>();
    final theme = Theme.of(context);
    final isOwner = auth.isOrganizer &&
        event.organizerEmail == auth.userEmail;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          // Hero app bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(event.title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.event,
                      size: 80, color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ),
            actions: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EventFormScreen(event: event)),
                  ),
                ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(context, l, ep),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info cards
                  _InfoCard(children: [
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: l.date,
                      value: DateFormat('EEEE dd MMM yyyy – HH:mm')
                          .format(event.date),
                    ),
                    _InfoRow(
                      icon: Icons.location_on,
                      label: l.location,
                      value: event.location,
                    ),
                    if (event.categoryName != null)
                      _InfoRow(
                        icon: Icons.category,
                        label: l.category,
                        value: event.categoryName!,
                      ),
                    _InfoRow(
                      icon: Icons.person,
                      label: l.organizer,
                      value: event.organizerName,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  if (event.description.isNotEmpty) ...[
                    Text(l.description,
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(event.description,
                            style: const TextStyle(
                                height: 1.6, color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // ORGANIZER actions
                  if (isOwner) ...[
                    _ActionButton(
                      icon: Icons.person_add,
                      label: l.inviteGuest,
                      color: theme.colorScheme.primary,
                      onTap: () => _showInviteDialog(context, l),
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      icon: Icons.qr_code_scanner,
                      label: l.scanQr,
                      color: theme.colorScheme.secondary,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const QrScannerScreen())),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppLocalizations l, EventProvider ep) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.deleteEvent),
        content: Text(l.confirmDelete),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.no)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await ep.deleteEvent(event.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l.yes,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context, AppLocalizations l) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l.inviteGuest),
          content: TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l.guestEmail,
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.cancel)),
            ElevatedButton(
              onPressed: () async {
                final email = emailCtrl.text.trim();
                if (email.isEmpty) return;
                Navigator.pop(ctx);
                final inv =
                    ctx.read<InvitationProvider>();
                final ok = await inv.inviteGuest(event.id, email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? l.inviteSent : (inv.error ?? l.error)),
                    backgroundColor:
                        ok ? Colors.green : Colors.red.shade700,
                  ));
                }
              },
              child: Text(l.invite),
            ),
          ],
        );
      },
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}