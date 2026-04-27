package com.brahim.eventhub.exception;

/**
 * Exception thrown when a resource already exists in the system.
 *
 * @author EventHub Team
 */
public class ResourceAlreadyExistsException extends RuntimeException {
    public ResourceAlreadyExistsException(String message) {
        super(message);
    }
}
