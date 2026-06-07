package com.eventhub.dto;

import jakarta.validation.constraints.NotBlank;

public class QrVerifyRequest {

    @NotBlank(message = "QR code is required")
    private String qrCode;

    public QrVerifyRequest() {}

    public String getQrCode() {
        return qrCode;
    }

    public void setQrCode(String qrCode) {
        this.qrCode = qrCode;
    }
}
