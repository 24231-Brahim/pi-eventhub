package com.brahim.eventhub.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * Request DTO for creating an invitation.
 *
 * @author EventHub Team
 */
public class InvitationRequest {

    @NotNull(message = "Event ID is required")
    private Integer eventId;

    @NotBlank(message = "Guest email is required")
    @Email(message = "Invalid email format")
    private String guestEmail;

    public InvitationRequest() {}

    public Integer getEventId() { return eventId; }
    public void setEventId(Integer eventId) { this.eventId = eventId; }

    public String getGuestEmail() { return guestEmail; }
    public void setGuestEmail(String guestEmail) { this.guestEmail = guestEmail; }
}