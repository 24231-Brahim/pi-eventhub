package com.brahim.eventhub.exception;

/**
 * Exception thrown for access denied scenarios.
 *
 * @author EventHub Team
 */
public class AccessDeniedException extends RuntimeException {
    public AccessDeniedException(String message) {
        super(message);
    }
}