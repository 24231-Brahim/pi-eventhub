import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eventhub/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub/features/tickets/presentation/bloc/ticket_bloc.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  DateTime _lastScan = DateTime.now();
  static const Duration _debounceDuration = Duration(seconds: 2);
  PermissionStatus? _cameraPermissionStatus;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() => _cameraPermissionStatus = status);
  }

  void _onDetect(BarcodeCapture capture, TicketBloc bloc) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    final now = DateTime.now();
    if (now.difference(_lastScan) < _debounceDuration) return;
    _lastScan = now;
    bloc.add(ValidateTicketEvent(qrData: barcode!.rawValue!));
  }

  void _showResultDialog(
    BuildContext context, {
    required IconData icon,
    required Color accentColor,
    required String title,
    required Widget content,
  }) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: AppSpacing.stackMd),
            Expanded(
              child: Text(
                title,
                style: AppTypography.sectionHeader
                    .copyWith(color: AppColors.onSurface),
              ),
            ),
          ],
        ),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.ok,
              style: AppTypography.labelLg
                  .copyWith(color: AppColors.vibrantGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showValidationResult(BuildContext context, TicketState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state is TicketValidated) {
      final ticket = state.ticket;
      switch (ticket.status) {
        case TicketStatus.used:
          _showResultDialog(
            context,
            icon: Icons.warning_amber_rounded,
            accentColor: AppColors.warning,
            title: l10n.alreadyUsed,
            content: Text(
              l10n.ticketAlreadyUsedMessage,
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
          );
        case TicketStatus.cancelled:
          _showResultDialog(
            context,
            icon: Icons.cancel,
            accentColor: AppColors.error,
            title: l10n.invalidTicket,
            content: Text(
              l10n.ticketCancelledMessage,
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
          );
        case TicketStatus.active:
          _showResultDialog(
            context,
            icon: Icons.check_circle,
            accentColor: AppColors.vibrantGreen,
            title: l10n.validTicket,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.ticketID}: ${ticket.id}',
                  style: AppTypography.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
                if (ticket.eventTitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${l10n.eventLabel}: ${ticket.eventTitle}',
                      style: AppTypography.bodyMd
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                const SizedBox(height: AppSpacing.stackSm),
                Text(
                  l10n.checkInSuccessful,
                  style: AppTypography.labelLg
                      .copyWith(color: AppColors.vibrantGreen),
                ),
              ],
            ),
          );
      }
    }
    if (state is TicketError) {
      _showResultDialog(
        context,
        icon: Icons.error,
        accentColor: AppColors.error,
        title: l10n.invalidTicket,
        content: Text(
          state.message,
          style:
              AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.obsidian,
        title: Text(l10n.scanQRCode),
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final status = _cameraPermissionStatus;
    if (status == null) {
      return const Center(child: LoadingWidget());
    }
    if (!status.isGranted) {
      return _CameraPermissionDenied(
        isPermanentlyDenied: status.isPermanentlyDenied,
        onRequestPermission: _requestCameraPermission,
      );
    }
    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) => _showValidationResult(context, state),
      child: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          return Stack(
            children: [
              MobileScanner(
                onDetect: (capture) =>
                    _onDetect(capture, context.read<TicketBloc>()),
              ),
              const Positioned.fill(
                child: IgnorePointer(child: _ScannerOverlay()),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 48,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.stackMd,
                      vertical: AppSpacing.stackSm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.obsidian.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      l10n.pointCameraAtQRCode,
                      style: AppTypography.bodyMd
                          .copyWith(color: AppColors.onSurface),
                    ),
                  ),
                ),
              ),
              if (state is TicketLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.obsidian.withValues(alpha: 0.6),
                    child: const Center(child: LoadingWidget()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CameraPermissionDenied extends StatelessWidget {
  final bool isPermanentlyDenied;
  final VoidCallback onRequestPermission;

  const _CameraPermissionDenied({
    required this.isPermanentlyDenied,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.videocam_off,
                  color: AppColors.error, size: 32),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            Text(
              l10n.cameraPermissionRequired,
              textAlign: TextAlign.center,
              style: AppTypography.sectionHeader
                  .copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            Text(
              l10n.cameraPermissionDeniedMessage,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            ElevatedButton(
              onPressed:
                  isPermanentlyDenied ? openAppSettings : onRequestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vibrantGreen,
                foregroundColor: AppColors.obsidian,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                isPermanentlyDenied ? l10n.openSettings : l10n.grantPermission,
                style: AppTypography.labelLg
                    .copyWith(color: AppColors.obsidian),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ScannerOverlayPainter());
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cutoutSize = size.shortestSide * 0.7;
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutoutSize,
      height: cutoutSize,
    );
    final cutoutRRect =
        RRect.fromRectAndRadius(cutoutRect, const Radius.circular(24));

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(cutoutRRect);
    final overlayPath =
        Path.combine(PathOperation.difference, backgroundPath, cutoutPath);

    canvas.drawPath(
      overlayPath,
      Paint()..color = AppColors.obsidian.withValues(alpha: 0.6),
    );

    canvas.drawRRect(
      cutoutRRect,
      Paint()
        ..color = AppColors.vibrantGreen.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    const cornerLength = 28.0;
    final cornerPaint = Paint()
      ..color = AppColors.vibrantGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final l = cutoutRect.left;
    final t = cutoutRect.top;
    final r = cutoutRect.right;
    final b = cutoutRect.bottom;

    // Top-left
    canvas.drawLine(Offset(l, t + cornerLength), Offset(l, t), cornerPaint);
    canvas.drawLine(Offset(l, t), Offset(l + cornerLength, t), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(r - cornerLength, t), Offset(r, t), cornerPaint);
    canvas.drawLine(Offset(r, t), Offset(r, t + cornerLength), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(l, b - cornerLength), Offset(l, b), cornerPaint);
    canvas.drawLine(Offset(l, b), Offset(l + cornerLength, b), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(r - cornerLength, b), Offset(r, b), cornerPaint);
    canvas.drawLine(Offset(r, b), Offset(r, b - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
