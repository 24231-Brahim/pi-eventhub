package com.brahim.eventhub.service;

import com.brahim.eventhub.dto.*;

/**
 * Service interface for authentication operations.
 *
 * @author EventHub Team
 */
public interface AuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
}