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
 * Implementation of InvitationService for invitation operations.
 *
 * @author EventHub Team
 */
@Service
@Transactional
public class InvitationServiceImpl implements InvitationService {

    private final InvitationRepository invitationRepository;
    private final EventRepository eventRepository;
    private final UserRepository userRepository;

    public InvitationServiceImpl(InvitationRepository invitationRepository, EventRepository eventRepository,
                       UserRepository userRepository) {
        this.invitationRepository = invitationRepository;
        this.eventRepository = eventRepository;
        this.userRepository = userRepository;
    }

    @Override
    public InvitationResponse createInvitation(InvitationRequest request, String organizerEmail) {
        User organizer = userRepository.findByEmail(organizerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Organizer not found"));

        if (organizer.getRole() != Role.ORGANIZER) {
            throw new AccessDeniedException("Only organizers can create invitations");
        }

        Event event = eventRepository.findByIdWithDetails(request.getEventId());
        if (event == null) {
            throw new ResourceNotFoundException("Event not found with id: " + request.getEventId());
        }

        if (!event.getOrganizer().getEmail().equals(organizerEmail)) {
            throw new AccessDeniedException("Only the event organizer can invite guests");
        }

        User guest = userRepository.findByEmail(request.getGuestEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Guest not found with email: " + request.getGuestEmail()));

        if (guest.getRole() != Role.GUEST) {
            throw new AccessDeniedException("Invitations can only be sent to guests");
        }

        if (invitationRepository.existsByEventIdAndGuestId(event.getId(), guest.getId())) {
            throw new AccessDeniedException("Guest already invited to this event");
        }

        Invitation invitation = Invitation.builder()
                .event(event)
                .guest(guest)
                .status(InvitationStatus.PENDING)
                .build();

        invitation = invitationRepository.save(invitation);
        return toResponse(invitation);
    }

    @Override
    @Transactional(readOnly = true)
    public List<InvitationResponse> getMyInvitations(String guestEmail) {
        User guest = userRepository.findByEmail(guestEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Guest not found"));

        return invitationRepository.findByGuestIdWithDetails(guest.getId()).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public String verifyQrCode(String qrCode) {
        Invitation invitation = invitationRepository.findByQrCode(qrCode)
                .orElseThrow(() -> new InvalidQrCodeException("Invalid QR code"));

        if (invitation.getStatus() == InvitationStatus.USED) {
            return "Invitation already used";
        }

        invitation.setStatus(InvitationStatus.USED);
        invitationRepository.save(invitation);

        return "Invitation verified successfully for event: " + invitation.getEvent().getTitle();
    }

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