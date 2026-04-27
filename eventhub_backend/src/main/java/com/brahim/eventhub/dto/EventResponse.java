package com.brahim.eventhub.dto;

import java.time.LocalDateTime;

/**
 * Response DTO for Event entity.
 *
 * @author EventHub Team
 */
public class EventResponse {
    private Integer id;
    private String title;
    private String description;
    private LocalDateTime date;
    private String location;
    private String categoryName;
    private String organizerName;
    private String organizerEmail;

    public EventResponse() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDateTime getDate() { return date; }
    public void setDate(LocalDateTime date) { this.date = date; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getOrganizerName() { return organizerName; }
    public void setOrganizerName(String organizerName) { this.organizerName = organizerName; }

    public String getOrganizerEmail() { return organizerEmail; }
    public void setOrganizerEmail(String organizerEmail) { this.organizerEmail = organizerEmail; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final EventResponse response = new EventResponse();

        public Builder id(Integer id) { response.id = id; return this; }
        public Builder title(String title) { response.title = title; return this; }
        public Builder description(String description) { response.description = description; return this; }
        public Builder date(LocalDateTime date) { response.date = date; return this; }
        public Builder location(String location) { response.location = location; return this; }
        public Builder categoryName(String categoryName) { response.categoryName = categoryName; return this; }
        public Builder organizerName(String organizerName) { response.organizerName = organizerName; return this; }
        public Builder organizerEmail(String organizerEmail) { response.organizerEmail = organizerEmail; return this; }
        public EventResponse build() { return response; }
    }
}