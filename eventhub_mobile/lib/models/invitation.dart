class Invitation {
  final int id;
  final int eventId;
  final String eventTitle;
  final String guestName;
  final String guestEmail;
  final String qrCode;
  final String status; // "PENDING" | "USED"

  const Invitation({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.guestName,
    required this.guestEmail,
    required this.qrCode,
    required this.status,
  });

  bool get isPending => status == 'PENDING';

  factory Invitation.fromJson(Map<String, dynamic> json) => Invitation(
        id: json['id'] as int,
        eventId: json['eventId'] as int,
        eventTitle: json['eventTitle'] as String,
        guestName: json['guestName'] as String,
        guestEmail: json['guestEmail'] as String,
        qrCode: json['qrCode'] as String,
        status: json['status'] as String,
      );
}
