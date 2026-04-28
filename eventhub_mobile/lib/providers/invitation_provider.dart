import 'package:flutter/material.dart';
import '../models/invitation.dart';
import '../services/invitation_service.dart';

class InvitationProvider extends ChangeNotifier {
  final InvitationService _service = InvitationService();

  List<Invitation> _invitations = [];
  bool _loading = false;
  String? _error;
  String? _verifyResult;

  List<Invitation> get invitations => _invitations;
  bool get loading => _loading;
  String? get error => _error;
  String? get verifyResult => _verifyResult;

  Future<void> loadMyInvitations() async {
    _setLoading(true);
    try {
      _invitations = await _service.getMyInvitations();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> inviteGuest(int eventId, String guestEmail) async {
    _setLoading(true);
    try {
      await _service.create(eventId, guestEmail);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> verifyQrCode(String qrCode) async {
    _setLoading(true);
    try {
      _verifyResult = await _service.verifyQrCode(qrCode);
      _error = null;
      notifyListeners();
      return _verifyResult!;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _error = msg;
      _verifyResult = msg;
      notifyListeners();
      return msg;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
