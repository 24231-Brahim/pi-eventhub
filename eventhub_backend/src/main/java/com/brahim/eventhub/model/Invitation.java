package com.brahim.eventhub.model;

import jakarta.persistence.*;
import java.util.UUID;

/**
 * Entity representing an invitation to an event.
 *
 * @author EventHub Team
 */
@Entity
@Table(name = "invitations")
public class Invitation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "event_id", nullable = false)
    private Event event;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "guest_id", nullable = false)
    private User guest;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private InvitationStatus status = InvitationStatus.PENDING;

    @Column(nullable = false, unique = true)
    private String qrCode;

    public Invitation() {}

    @PrePersist
    public void prePersist() {
        if (qrCode == null) {
            qrCode = UUID.randomUUID().toString();
        }
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Event getEvent() { return event; }
    public void setEvent(Event event) { this.event = event; }

    public User getGuest() { return guest; }
    public void setGuest(User guest) { this.guest = guest; }

    public InvitationStatus getStatus() { return status; }
    public void setStatus(InvitationStatus status) { this.status = status; }

    public String getQrCode() { return qrCode; }
    public void setQrCode(String qrCode) { this.qrCode = qrCode; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final Invitation invitation = new Invitation();

        public Builder id(Integer id) { invitation.id = id; return this; }
        public Builder event(Event event) { invitation.event = event; return this; }
        public Builder guest(User guest) { invitation.guest = guest; return this; }
        public Builder status(InvitationStatus status) { invitation.status = status; return this; }
        public Builder qrCode(String qrCode) { invitation.qrCode = qrCode; return this; }
        public Invitation build() { return invitation; }
    }

    public boolean isPending() {
        return status == InvitationStatus.PENDING;
    }
}