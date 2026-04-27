package com.brahim.eventhub.dto;

/**
 * Response DTO for Invitation entity.
 *
 * @author EventHub Team
 */
public class InvitationResponse {
    private Integer id;
    private Integer eventId;
    private String eventTitle;
    private String guestName;
    private String guestEmail;
    private String qrCode;
    private String status;

    public InvitationResponse() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getEventId() { return eventId; }
    public void setEventId(Integer eventId) { this.eventId = eventId; }

    public String getEventTitle() { return eventTitle; }
    public void setEventTitle(String eventTitle) { this.eventTitle = eventTitle; }

    public String getGuestName() { return guestName; }
    public void setGuestName(String guestName) { this.guestName = guestName; }

    public String getGuestEmail() { return guestEmail; }
    public void setGuestEmail(String guestEmail) { this.guestEmail = guestEmail; }

    public String getQrCode() { return qrCode; }
    public void setQrCode(String qrCode) { this.qrCode = qrCode; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final InvitationResponse response = new InvitationResponse();

        public Builder id(Integer id) { response.id = id; return this; }
        public Builder eventId(Integer eventId) { response.eventId = eventId; return this; }
        public Builder eventTitle(String eventTitle) { response.eventTitle = eventTitle; return this; }
        public Builder guestName(String guestName) { response.guestName = guestName; return this; }
        public Builder guestEmail(String guestEmail) { response.guestEmail = guestEmail; return this; }
        public Builder qrCode(String qrCode) { response.qrCode = qrCode; return this; }
        public Builder status(String status) { response.status = status; return this; }
        public InvitationResponse build() { return response; }
    }
}