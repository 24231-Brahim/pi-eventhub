package com.brahim.eventhub.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Entity representing an event organized by a user.
 *
 * @author EventHub Team
 */
@Entity
@Table(name = "events")
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private LocalDateTime date;

    @Column(nullable = false)
    private String location;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizer_id", nullable = false)
    private User organizer;

    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Invitation> invitations = new ArrayList<>();

    public Event() {}

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

    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }

    public User getOrganizer() { return organizer; }
    public void setOrganizer(User organizer) { this.organizer = organizer; }

    public List<Invitation> getInvitations() { return invitations; }
    public void setInvitations(List<Invitation> invitations) { this.invitations = invitations; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final Event event = new Event();

        public Builder id(Integer id) { event.id = id; return this; }
        public Builder title(String title) { event.title = title; return this; }
        public Builder description(String description) { event.description = description; return this; }
        public Builder date(LocalDateTime date) { event.date = date; return this; }
        public Builder location(String location) { event.location = location; return this; }
        public Builder category(Category category) { event.category = category; return this; }
        public Builder organizer(User organizer) { event.organizer = organizer; return this; }
        public Event build() { return event; }
    }
}