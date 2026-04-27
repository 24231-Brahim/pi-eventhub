package com.brahim.eventhub.exception;

/**
 * Exception thrown when email already exists in the system.
 *
 * @author EventHub Team
 */
public class EmailAlreadyExistsException extends RuntimeException {
    public EmailAlreadyExistsException(String message) {
        super(message);
    }
}