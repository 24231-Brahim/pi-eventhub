import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventhub_app/l10n/app_localizations.dart';
import '../../models/invitation.dart';
import '../../providers/invitation_provider.dart';
import 'qr_display_screen.dart';

class MyInvitationsScreen extends StatefulWidget {
  const MyInvitationsScreen({super.key});

  @override
  State<MyInvitationsScreen> createState() => _MyInvitationsScreenState();
}

class _MyInvitationsScreenState extends State<MyInvitationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvitationProvider>().loadMyInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final inv = context.watch<InvitationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(l.myInvitations,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: inv.loading
          ? const Center(child: CircularProgressIndicator())
          : inv.error != null
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(inv.error!,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<InvitationProvider>().loadMyInvitations(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ))
              : inv.invitations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(l.noInvitations,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => context
                          .read<InvitationProvider>()
                          .loadMyInvitations(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: inv.invitations.length,
                        itemBuilder: (_, i) =>
                            _InvitationCard(invitation: inv.invitations[i]),
                      ),
                    ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final Invitation invitation;
  const _InvitationCard({required this.invitation});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isPending = invitation.isPending;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  QrDisplayScreen(invitation: invitation)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // QR icon block
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPending
                        ? [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary
                          ]
                        : [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.qr_code,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invitation.eventTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isPending
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPending
                                  ? Colors.green.shade300
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            isPending ? l.pending : l.used,
                            style: TextStyle(
                                color: isPending
                                    ? Colors.green.shade700
                                    : Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invitation.qrCode.substring(0, 8) + '...',
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              Icon(Icons.qr_code_2,
                  color: theme.colorScheme.primary, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
