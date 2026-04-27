package com.brahim.eventhub.exception;

/**
 * Exception thrown for authentication failures.
 *
 * @author EventHub Team
 */
public class AuthenticationException extends RuntimeException {
    public AuthenticationException(String message) {
        super(message);
    }
}