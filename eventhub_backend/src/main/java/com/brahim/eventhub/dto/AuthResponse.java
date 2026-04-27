package com.brahim.eventhub.dto;

/**
 * Response DTO for authentication operations.
 *
 * @author EventHub Team
 */
public class AuthResponse {
    private String token;
    private String email;
    private String name;
    private String role;

    public AuthResponse() {}

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final AuthResponse response = new AuthResponse();

        public Builder token(String token) { response.token = token; return this; }
        public Builder email(String email) { response.email = email; return this; }
        public Builder name(String name) { response.name = name; return this; }
        public Builder role(String role) { response.role = role; return this; }
        public AuthResponse build() { return response; }
    }
}