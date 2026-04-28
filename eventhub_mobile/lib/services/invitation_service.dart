import '../models/invitation.dart';
import 'api_service.dart';

class InvitationService {
  Future<Invitation> create(int eventId, String guestEmail) async {
    final response = await ApiService.post('/invitations', {
      'eventId': eventId,
      'guestEmail': guestEmail,
    });
    return Invitation.fromJson(
        ApiService.parseResponse(response) as Map<String, dynamic>);
  }

  Future<List<Invitation>> getMyInvitations() async {
    final response = await ApiService.get('/invitations/my');
    final list = ApiService.parseResponse(response) as List<dynamic>;
    return list
        .map((i) => Invitation.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<String> verifyQrCode(String qrCode) async {
    final response = await ApiService.post('/invitations/verify', {
      'qrCode': qrCode,
    });
    final data = ApiService.parseResponse(response) as Map<String, dynamic>;
    return data['message'] as String? ?? 'Verified';
  }
}
