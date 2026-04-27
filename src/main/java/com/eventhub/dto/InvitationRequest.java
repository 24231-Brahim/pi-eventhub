package com.eventhub.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class InvitationRequest {

    @NotNull(message = "Event ID is required")
    private Long eventId;

    @NotBlank(message = "Guest email is required")
    @Email(message = "Invalid email format")
    private String guestEmail;
}
