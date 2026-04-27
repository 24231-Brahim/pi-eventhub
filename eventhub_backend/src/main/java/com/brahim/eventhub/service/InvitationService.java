package com.brahim.eventhub.service;

import com.brahim.eventhub.dto.InvitationRequest;
import com.brahim.eventhub.dto.InvitationResponse;

import java.util.List;

/**
 * Service interface for invitation operations.
 *
 * @author EventHub Team
 */
public interface InvitationService {
    InvitationResponse createInvitation(InvitationRequest request, String organizerEmail);
    List<InvitationResponse> getMyInvitations(String guestEmail);
    String verifyQrCode(String qrCode);
}