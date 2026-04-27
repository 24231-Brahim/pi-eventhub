package com.brahim.eventhub.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Request DTO for verifying a QR code.
 *
 * @author EventHub Team
 */
public class VerifyQrCodeRequest {

    @NotBlank(message = "QR code is required")
    private String qrCode;

    public VerifyQrCodeRequest() {}

    public String getQrCode() { return qrCode; }
    public void setQrCode(String qrCode) { this.qrCode = qrCode; }
}