package com.eventhub.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class EventRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private String description;

    @NotNull(message = "Date is required")
    @Future(message = "Event date must be in the future")
    private LocalDateTime date;

    @NotBlank(message = "Location is required")
    private String location;

    private Long categoryId;
}
