package com.eventhub.controller;

import com.eventhub.dto.InvitationRequest;
import com.eventhub.dto.InvitationResponse;
import com.eventhub.dto.QrVerifyRequest;
import com.eventhub.service.InvitationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/invitations")
@RequiredArgsConstructor
public class InvitationController {

    private final InvitationService invitationService;

    /**
     * POST /api/invitations
     * Invite a guest by email to an event. Generates a UUID QR code.
     */
    @PostMapping
    public ResponseEntity<InvitationResponse> createInvitation(
            @Valid @RequestBody InvitationRequest request
    ) {
        InvitationResponse response = invitationService.createInvitation(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * GET /api/invitations/my
     * Returns all invitations for the currently authenticated guest.
     */
    @GetMapping("/my")
    public ResponseEntity<List<InvitationResponse>> getMyInvitations(
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        List<InvitationResponse> invitations = invitationService.getMyInvitations(userDetails.getUsername());
        return ResponseEntity.ok(invitations);
    }

    /**
     * POST /api/invitations/verify
     * Verifies a QR code and marks the invitation as USED.
     * Body: { "qrCode": "uuid-string" }
     */
    @PostMapping("/verify")
    public ResponseEntity<Map<String, String>> verifyQrCode(
            @Valid @RequestBody QrVerifyRequest request
    ) {
        String message = invitationService.verifyQrCode(request);
        return ResponseEntity.ok(Map.of("message", message, "status", "SUCCESS"));
    }
}
