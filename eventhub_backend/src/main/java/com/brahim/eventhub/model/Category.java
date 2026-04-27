package com.brahim.eventhub.model;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Entity representing an event category.
 *
 * @author EventHub Team
 */
@Entity
@Table(name = "categories")
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true)
    private String name;

    @OneToMany(mappedBy = "category", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Event> events = new ArrayList<>();

    public Category() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public List<Event> getEvents() { return events; }
    public void setEvents(List<Event> events) { this.events = events; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final Category category = new Category();

        public Builder id(Integer id) { category.id = id; return this; }
        public Builder name(String name) { category.name = name; return this; }
        public Category build() { return category; }
    }

    @Override
    public String toString() {
        return name;
    }
}