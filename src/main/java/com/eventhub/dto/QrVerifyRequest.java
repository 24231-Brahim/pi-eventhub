package com.eventhub.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class QrVerifyRequest {

    @NotBlank(message = "QR code is required")
    private String qrCode;
}
