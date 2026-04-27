package com.brahim.eventhub.exception;

/**
 * Exception thrown when a requested resource is not found.
 *
 * @author EventHub Team
 */
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}