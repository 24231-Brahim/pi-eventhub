package com.brahim.eventhub.model;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Entity representing a user in the EventHub system.
 * Users can be either ORGANIZER or GUEST based on their role.
 *
 * @author EventHub Team
 */
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @OneToMany(mappedBy = "organizer", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Event> organizedEvents = new ArrayList<>();

    @OneToMany(mappedBy = "guest", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Invitation> invitations = new ArrayList<>();

    public User() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }

    public List<Event> getOrganizedEvents() { return organizedEvents; }
    public void setOrganizedEvents(List<Event> organizedEvents) { this.organizedEvents = organizedEvents; }

    public List<Invitation> getInvitations() { return invitations; }
    public void setInvitations(List<Invitation> invitations) { this.invitations = invitations; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final User user = new User();

        public Builder id(Integer id) { user.id = id; return this; }
        public Builder name(String name) { user.name = name; return this; }
        public Builder email(String email) { user.email = email; return this; }
        public Builder password(String password) { user.password = password; return this; }
        public Builder role(Role role) { user.role = role; return this; }
        public User build() { return user; }
    }

    public boolean isOrganizer() {
        return role == Role.ORGANIZER;
    }
}