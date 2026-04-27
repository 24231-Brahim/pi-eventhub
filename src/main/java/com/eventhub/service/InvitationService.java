package com.eventhub.service;

import com.eventhub.dto.InvitationRequest;
import com.eventhub.dto.InvitationResponse;
import com.eventhub.dto.QrVerifyRequest;
import com.eventhub.model.Event;
import com.eventhub.model.Invitation;
import com.eventhub.model.User;
import com.eventhub.repository.EventRepository;
import com.eventhub.repository.InvitationRepository;
import com.eventhub.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class InvitationService {

    private final InvitationRepository invitationRepository;
    private final EventRepository eventRepository;
    private final UserRepository userRepository;

    public InvitationService(InvitationRepository invitationRepository, EventRepository eventRepository, UserRepository userRepository) {
        this.invitationRepository = invitationRepository;
        this.eventRepository = eventRepository;
        this.userRepository = userRepository;
    }

    /**
     * Create an invitation for a guest (looked up by email) to an event.
     * Generates a UUID as the QR code value.
     */
    public InvitationResponse createInvitation(InvitationRequest request) {
        Event event = eventRepository.findById(request.getEventId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Event not found"));

        User guest = userRepository.findByEmail(request.getGuestEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "No user found with email: " + request.getGuestEmail()));

        String qrCode = UUID.randomUUID().toString();

        Invitation invitation = new Invitation();
        invitation.setEvent(event);
        invitation.setGuest(guest);
        invitation.setQrCode(qrCode);
        invitation.setStatus(Invitation.Status.PENDING);

        return toResponse(invitationRepository.save(invitation));
    }

    /**
     * Returns all invitations for the currently authenticated guest.
     */
    public List<InvitationResponse> getMyInvitations(String guestEmail) {
        User guest = userRepository.findByEmail(guestEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        return invitationRepository.findByGuest(guest)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Verifies a QR code: changes status from PENDING → USED.
     * Returns a descriptive message.
     */
    public String verifyQrCode(QrVerifyRequest request) {
        Invitation invitation = invitationRepository.findByQrCode(request.getQrCode())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Invalid QR code"));

        if (invitation.getStatus() == Invitation.Status.USED) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "QR code has already been used");
        }

        invitation.setStatus(Invitation.Status.USED);
        invitationRepository.save(invitation);

        return "QR code verified successfully. Invitation for event '" +
                invitation.getEvent().getTitle() + "' marked as USED.";
    }

    // ── Mapper ───────────────────────────────────────────────────────

    private InvitationResponse toResponse(Invitation invitation) {
        return new InvitationResponse(
                invitation.getId(),
                invitation.getEvent().getId(),
                invitation.getEvent().getTitle(),
                invitation.getGuest().getName(),
                invitation.getGuest().getEmail(),
                invitation.getQrCode(),
                invitation.getStatus().name()
        );
    }
}
