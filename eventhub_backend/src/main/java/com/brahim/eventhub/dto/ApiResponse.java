package com.brahim.eventhub.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * Unified API response wrapper for consistent JSON responses.
 *
 * @author EventHub Team
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {
    private String status;
    private String message;
    private T data;

    public ApiResponse() {}

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public T getData() { return data; }
    public void setData(T data) { this.data = data; }

    public static <T> ApiResponse<T> success(T data) {
        ApiResponse<T> response = new ApiResponse<>();
        response.status = "success";
        response.data = data;
        return response;
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        ApiResponse<T> response = new ApiResponse<>();
        response.status = "success";
        response.message = message;
        response.data = data;
        return response;
    }

    public static <T> ApiResponse<T> error(String message) {
        ApiResponse<T> response = new ApiResponse<>();
        response.status = "error";
        response.message = message;
        return response;
    }

    public static <T> ApiResponse<T> error(String message, T data) {
        ApiResponse<T> response = new ApiResponse<>();
        response.status = "error";
        response.message = message;
        response.data = data;
        return response;
    }

    public static <T> Builder<T> builder() { return new Builder<>(); }

    public static class Builder<T> {
        private final ApiResponse<T> response = new ApiResponse<>();

        public Builder<T> status(String status) { response.status = status; return this; }
        public Builder<T> message(String message) { response.message = message; return this; }
        public Builder<T> data(T data) { response.data = data; return this; }
        public ApiResponse<T> build() { return response; }
    }
}