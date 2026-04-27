package com.brahim.eventhub.controller;

import com.brahim.eventhub.dto.*;
import com.brahim.eventhub.service.InvitationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST controller for invitation endpoints.
 *
 * @author EventHub Team
 */
@RestController
@RequestMapping("/api/invitations")
@Tag(name = "Invitations", description = "Invitation management endpoints")
@SecurityRequirement(name = "Bearer Authentication")
public class InvitationController {

    private final InvitationService invitationService;

    public InvitationController(InvitationService invitationService) {
        this.invitationService = invitationService;
    }

    @PostMapping
    @Operation(summary = "Create a new invitation")
    public ResponseEntity<ApiResponse<InvitationResponse>> createInvitation(
            @Valid @RequestBody InvitationRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        InvitationResponse response = invitationService.createInvitation(request, userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Invitation created successfully", response));
    }

    @GetMapping("/my")
    @Operation(summary = "Get my invitations")
    public ResponseEntity<ApiResponse<List<InvitationResponse>>> getMyInvitations(
            @AuthenticationPrincipal UserDetails userDetails) {
        List<InvitationResponse> invitations = invitationService.getMyInvitations(userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success(invitations));
    }

    @PostMapping("/verify")
    @Operation(summary = "Verify QR code")
    public ResponseEntity<ApiResponse<Map<String, String>>> verifyQrCode(
            @Valid @RequestBody VerifyQrCodeRequest request) {
        String message = invitationService.verifyQrCode(request.getQrCode());
        return ResponseEntity.ok(ApiResponse.success(Map.of("message", message)));
    }
}