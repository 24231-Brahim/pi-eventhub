package com.eventhub.dto;

public class InvitationResponse {
    private Long id;
    private Long eventId;
    private String eventTitle;
    private String guestName;
    private String guestEmail;
    private String qrCode;
    private String status;

    public InvitationResponse() {}

    public InvitationResponse(Long id, Long eventId, String eventTitle, String guestName, String guestEmail, String qrCode, String status) {
        this.id = id;
        this.eventId = eventId;
        this.eventTitle = eventTitle;
        this.guestName = guestName;
        this.guestEmail = guestEmail;
        this.qrCode = qrCode;
        this.status = status;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getEventId() {
        return eventId;
    }

    public void setEventId(Long eventId) {
        this.eventId = eventId;
    }

    public String getEventTitle() {
        return eventTitle;
    }

    public void setEventTitle(String eventTitle) {
        this.eventTitle = eventTitle;
    }

    public String getGuestName() {
        return guestName;
    }

    public void setGuestName(String guestName) {
        this.guestName = guestName;
    }

    public String getGuestEmail() {
        return guestEmail;
    }

    public void setGuestEmail(String guestEmail) {
        this.guestEmail = guestEmail;
    }

    public String getQrCode() {
        return qrCode;
    }

    public void setQrCode(String qrCode) {
        this.qrCode = qrCode;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
