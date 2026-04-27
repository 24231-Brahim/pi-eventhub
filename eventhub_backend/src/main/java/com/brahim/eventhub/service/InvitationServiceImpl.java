/*
 * FICHIER : InvitationServiceImpl.java
 * RÔLE : Contient toute la logique métier pour la gestion des invitations
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier gère tout ce qui concerne les invitations.
 * Il vérifie que l'organisateur a le droit d'inviter, que l'invité existe et a le rôle GUEST,
 * et que l'invité n'est pas déjà invité à cet événement.
 * Il gère aussi la vérification des codes QR (utilisés pour valider la présence à l'événement).
 * UTILISÉ PAR : InvitationController qui reçoit les requêtes HTTP
 */

package com.brahim.eventhub.service;

import com.brahim.eventhub.dto.InvitationRequest;
import com.brahim.eventhub.dto.InvitationResponse;
import com.brahim.eventhub.exception.AccessDeniedException;
import com.brahim.eventhub.exception.InvalidQrCodeException;
import com.brahim.eventhub.exception.ResourceNotFoundException;
import com.brahim.eventhub.model.Event;
import com.brahim.eventhub.model.Invitation;
import com.brahim.eventhub.model.InvitationStatus;
import com.brahim.eventhub.model.Role;
import com.brahim.eventhub.model.User;
import com.brahim.eventhub.repository.EventRepository;
import com.brahim.eventhub.repository.InvitationRepository;
import com.brahim.eventhub.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Implémentation de l'interface InvitationService
 * @Service indique à Spring que c'est un composant métier
 * @Transactional garantit que toutes les opérations sur la base sont sécurisées
 */
@Service
@Transactional
public class InvitationServiceImpl implements InvitationService {

    // Accès à la table des invitations en base
    private final InvitationRepository invitationRepository;
    // Accès à la table des événements en base
    private final EventRepository eventRepository;
    // Accès à la table des utilisateurs en base
    private final UserRepository userRepository;

    // Constructeur avec injection de dépendances (Spring remplit automatiquement)
    public InvitationServiceImpl(InvitationRepository invitationRepository, EventRepository eventRepository,
                       UserRepository userRepository) {
        this.invitationRepository = invitationRepository;
        this.eventRepository = eventRepository;
        this.userRepository = userRepository;
    }

    /**
     * MÉTHODE : Créer une invitation (réservé aux organisateurs)
     * CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
     * 1. Vérifie que l'utilisateur connecté est bien un organisateur
     * 2. Récupère l'événement concerné et vérifie qu'il existe
     * 3. Vérifie que l'organisateur est bien le propriétaire de l'événement
     * 4. Récupère l'invité par son email et vérifie qu'il a le rôle GUEST
     * 5. Vérifie que l'invité n'est pas déjà invité à cet événement
     * 6. Crée l'invitation avec un code QR unique (généré automatiquement par @PrePersist)
     * 7. Sauvegarde en base et renvoie la réponse
     */
    @Override
    public InvitationResponse createInvitation(InvitationRequest request, String organizerEmail) {
        // Étape 1 : Trouver l'organisateur
        User organizer = userRepository.findByEmail(organizerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Organizer not found"));

        // Vérifier que c'est bien un organisateur
        if (organizer.getRole() != Role.ORGANIZER) {
            throw new AccessDeniedException("Only organizers can create invitations");
        }

        // Étape 2 : Trouver l'événement
        Event event = eventRepository.findByIdWithDetails(request.getEventId());
        if (event == null) {
            throw new ResourceNotFoundException("Event not found with id: " + request.getEventId());
        }

        // Étape 3 : Vérifier que l'organisateur est le propriétaire
        if (!event.getOrganizer().getEmail().equals(organizerEmail)) {
            throw new AccessDeniedException("Only the event organizer can invite guests");
        }

        // Étape 4 : Trouver l'invité (doit avoir le rôle GUEST)
        User guest = userRepository.findByEmail(request.getGuestEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Guest not found with email: " + request.getGuestEmail()));

        if (guest.getRole() != Role.GUEST) {
            throw new AccessDeniedException("Invitations can only be sent to guests");
        }

        // Étape 5 : Vérifier qu'il n'est pas déjà invité
        if (invitationRepository.existsByEventIdAndGuestId(event.getId(), guest.getId())) {
            throw new AccessDeniedException("Guest already invited to this event");
        }

        // Étape 6 : Créer l'invitation
        Invitation invitation = Invitation.builder()
                .event(event)
                .guest(guest)
                .status(InvitationStatus.PENDING) // Par défaut : en attente
                .build();
        // Le code QR est généré automatiquement par @PrePersist (UUID)

        // Étape 7 : Sauvegarder et renvoyer
        invitation = invitationRepository.save(invitation);
        return toResponse(invitation);
    }

    /**
     * MÉTHODE : Récupérer mes invitations (réservé aux invités)
     * CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
     * 1. Trouve l'utilisateur par son email
     * 2. Récupère toutes ses invitations avec les détails des événements
     * 3. Convertit en format de réponse et renvoie la liste
     * NOTE : Cette méthode est en lecture seule
     */
    @Override
    @Transactional(readOnly = true)
    public List<InvitationResponse> getMyInvitations(String guestEmail) {
        // Trouver l'invité
        User guest = userRepository.findByEmail(guestEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Guest not found"));

        // Récupérer toutes ses invitations avec les détails
        return invitationRepository.findByGuestIdWithDetails(guest.getId()).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * MÉTHODE : Vérifier un code QR (réservé aux organisateurs)
     * CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
     * 1. Cherche l'invitation correspondant au code QR
     * 2. Si le code QR n'existe pas, lance une erreur
     * 3. Vérifie si l'invitation n'a pas déjà été utilisée (statut USED)
     * 4. Si tout est OK, change le statut de PENDING à USED
     * 5. Sauvegarde en base et renvoie un message de confirmation
     */
    @Override
    public String verifyQrCode(String qrCode) {
        // Étape 1 : Chercher l'invitation par son code QR
        Invitation invitation = invitationRepository.findByQrCode(qrCode)
                .orElseThrow(() -> new InvalidQrCodeException("Invalid QR code"));

        // Étape 2 et 3 : Vérifier si déjà utilisé
        if (invitation.getStatus() == InvitationStatus.USED) {
            return "Invitation already used";
        }

        // Étape 4 : Marquer comme utilisé
        invitation.setStatus(InvitationStatus.USED);
        invitationRepository.save(invitation);

        // Étape 5 : Message de confirmation
        return "Invitation verified successfully for event: " + invitation.getEvent().getTitle();
    }

    /**
     * MÉTHODE PRIVÉE : Convertir une Invitation en InvitationResponse
     * CE QUE ÇA FAIT : Transforme l'entité brute de la base en un objet lisible
     * avec seulement les informations nécessaires pour l'application mobile
     */
    private InvitationResponse toResponse(Invitation invitation) {
        return InvitationResponse.builder()
                .id(invitation.getId())
                .eventId(invitation.getEvent().getId())
                .eventTitle(invitation.getEvent().getTitle())
                .guestName(invitation.getGuest().getName())
                .guestEmail(invitation.getGuest().getEmail())
                .qrCode(invitation.getQrCode())
                .status(invitation.getStatus().name())
                .build();
    }
}
