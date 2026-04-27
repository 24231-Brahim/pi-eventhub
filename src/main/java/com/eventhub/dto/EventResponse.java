package com.eventhub.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EventResponse {
    private Long id;
    private String title;
    private String description;
    private LocalDateTime date;
    private String location;
    private String categoryName;
    private String organizerName;
    private String organizerEmail;
}
