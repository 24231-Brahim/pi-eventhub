package com.brahim.eventhub.exception;

/**
 * Exception thrown when an invalid QR code is scanned.
 *
 * @author EventHub Team
 */
public class InvalidQrCodeException extends RuntimeException {
    public InvalidQrCodeException(String message) {
        super(message);
    }
}