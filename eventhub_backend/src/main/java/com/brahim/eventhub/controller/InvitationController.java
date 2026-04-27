/*
 * FICHIER : InvitationController.java
 * RÔLE : Gère toutes les requêtes liées aux invitations (création, liste, vérification QR)
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier gère tout ce qui concerne les invitations aux événements.
 * L'organisateur peut inviter des invités (GUEST) à ses événements, et scanner leurs QR codes.
 * L'invité peut consulter la liste de ses invitations reçues.
 * Chaque invitation a un code QR unique qui permet de vérifier la présence à l'événement.
 * UTILISÉ PAR : L'application mobile via les routes /api/invitations/*
 */

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

/**
 * C'est un contrôleur REST (gère les requêtes HTTP)
 * Le chemin de base pour toutes les méthodes ici est "/api/invitations"
 * SecurityRequirement indique que toutes les routes nécessitent un token JWT valide
 */
@RestController
@RequestMapping("/api/invitations")
@Tag(name = "Invitations", description = "Invitation management endpoints")
@SecurityRequirement(name = "Bearer Authentication")
public class InvitationController {

    // Le service qui contient la logique métier pour les invitations
    private final InvitationService invitationService;

    // Constructeur : Spring injecte automatiquement le InvitationService ici
    public InvitationController(InvitationService invitationService) {
        this.invitationService = invitationService;
    }

    /**
     * MÉTHODE : Créer une invitation (réservé aux organisateurs)
     * ROUTE : POST /api/invitations
     * CE QUE ÇA FAIT :
     * 1. Reçoit l'identifiant de l'événement et l'email de l'invité
     * 2. Vérifie que l'utilisateur connecté est bien l'organisateur de l'événement
     * 3. Vérifie que l'invité existe et a le rôle GUEST
     * 4. Vérifie que l'invité n'est pas déjà invité à cet événement
     * 5. Crée l'invitation avec un code QR unique (généré automatiquement)
     */
    @PostMapping
    @Operation(summary = "Create an invitation")
    public ResponseEntity<ApiResponse<InvitationResponse>> createInvitation(
            @Valid @RequestBody InvitationRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        // userDetails.getUsername() renvoie l'email de l'organisateur connecté
        InvitationResponse response = invitationService.createInvitation(request, userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Invitation sent successfully", response));
    }

    /**
     * MÉTHODE : Récupérer mes invitations (réservé aux invités)
     * ROUTE : GET /api/invitations/my
     * CE QUE ÇA FAIT :
     * 1. Récupère l'email de l'utilisateur connecté (qui doit avoir le rôle GUEST)
     * 2. Cherche toutes les invitations reçues par cet utilisateur
     * 3. Renvoie la liste avec les détails des événements concernés
     */
    @GetMapping("/my")
    @Operation(summary = "Get my invitations")
    public ResponseEntity<ApiResponse<List<InvitationResponse>>> getMyInvitations(
            @AuthenticationPrincipal UserDetails userDetails) {
        List<InvitationResponse> invitations = invitationService.getMyInvitations(userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success(invitations));
    }

    /**
     * MÉTHODE : Vérifier un code QR (réservé aux organisateurs)
     * ROUTE : POST /api/invitations/verify
     * CE QUE ÇA FAIT :
     * 1. Reçoit un code QR scanné par l'organisateur
     * 2. Cherche l'invitation correspondante en base
     * 3. Vérifie si le code QR n'a pas déjà été utilisé (statut PENDING)
     * 4. Si tout est OK, change le statut de PENDING à USED
     * 5. Renvoie un message de confirmation avec le nom de l'événement
     */
    @PostMapping("/verify")
    @Operation(summary = "Verify a QR code")
    public ResponseEntity<ApiResponse<String>> verifyQrCode(
            @Valid @RequestBody VerifyQrCodeRequest request) {
        String result = invitationService.verifyQrCode(request.getQrCode());
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
