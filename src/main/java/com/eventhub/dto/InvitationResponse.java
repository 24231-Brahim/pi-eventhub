package com.eventhub.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InvitationResponse {
    private Long id;
    private Long eventId;
    private String eventTitle;
    private String guestName;
    private String guestEmail;
    private String qrCode;
    private String status;
}
