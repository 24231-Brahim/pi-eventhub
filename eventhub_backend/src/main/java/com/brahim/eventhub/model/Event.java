/*
 * FICHIER : Event.java
 * RÔLE : Définit le modèle de données pour les événements (événements culturels, sportifs, etc.)
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier décrit ce qu'est un événement dans l'application EventHub.
 * Un événement a un titre, une description, une date, un lieu, une catégorie, et un organisateur.
 * Il peut aussi avoir plusieurs invitations (les personnes invitées à l'événement).
 * Ce fichier est utilisé par tous les services qui gèrent les événements, les catégories et les invitations.
 * UTILISÉ PAR : EventService, EventController, EventRepository, InvitationService
 */

package com.brahim.eventhub.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

// Indique que cette classe est une entité JPA liée à la table "events"
@Entity
@Table(name = "events")
public class Event {

    // Identifiant unique de l'événement (clé primaire, auto-généré)
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // Titre de l'événement (ne peut pas être vide)
    @Column(nullable = false)
    private String title;

    // Description détaillée de l'événement (peut être long texte)
    @Column(columnDefinition = "TEXT")
    private String description;

    // Date et heure de l'événement (ne peut pas être vide)
    @Column(nullable = false)
    private LocalDateTime date;

    // Lieu où se déroule l'événement (ne peut pas être vide)
    @Column(nullable = false)
    private String location;

    // Catégorie de l'événement (ex: Musique, Sport) - relation N:1 vers Category
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    // Organisateur de l'événement (utilisateur qui a créé l'événement) - relation N:1 vers User
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizer_id", nullable = false)
    private User organizer;

    // Liste des invitations envoyées pour cet événement - relation 1:N depuis Invitation
    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Invitation> invitations = new ArrayList<>();

    // Constructeur vide (obligatoire pour JPA/Hibernate)
    public Event() {}

    // Getters et setters : permettent de lire et modifier les propriétés de l'événement

    // Renvoie l'identifiant unique de l'événement
    public Integer getId() { return id; }
    // Modifie l'identifiant de l'événement
    public void setId(Integer id) { this.id = id; }

    // Renvoie le titre de l'événement
    public String getTitle() { return title; }
    // Modifie le titre de l'événement
    public void setTitle(String title) { this.title = title; }

    // Renvoie la description de l'événement
    public String getDescription() { return description; }
    // Modifie la description de l'événement
    public void setDescription(String description) { this.description = description; }

    // Renvoie la date et l'heure de l'événement
    public LocalDateTime getDate() { return date; }
    // Modifie la date et l'heure de l'événement
    public void setDate(LocalDateTime date) { this.date = date; }

    // Renvoie le lieu de l'événement
    public String getLocation() { return location; }
    // Modifie le lieu de l'événement
    public void setLocation(String location) { this.location = location; }

    // Renvoie la catégorie de l'événement (peut être null si non définie)
    public Category getCategory() { return category; }
    // Modifie la catégorie de l'événement
    public void setCategory(Category category) { this.category = category; }

    // Renvoie l'organisateur de l'événement
    public User getOrganizer() { return organizer; }
    // Modifie l'organisateur de l'événement
    public void setOrganizer(User organizer) { this.organizer = organizer; }

    // Renvoie la liste des invitations de cet événement
    public List<Invitation> getInvitations() { return invitations; }
    // Modifie la liste des invitations de cet événement
    public void setInvitations(List<Invitation> invitations) { this.invitations = invitations; }

    // Pattern Builder : permet de créer un objet Event étape par étape
    public static Builder builder() { return new Builder(); }

    // Classe interne Builder pour construire un objet Event facilement
    public static class Builder {
        private final Event event = new Event();

        // Définit l'identifiant de l'événement
        public Builder id(Integer id) { event.id = id; return this; }
        // Définit le titre de l'événement
        public Builder title(String title) { event.title = title; return this; }
        // Définit la description de l'événement
        public Builder description(String description) { event.description = description; return this; }
        // Définit la date de l'événement
        public Builder date(LocalDateTime date) { event.date = date; return this; }
        // Définit le lieu de l'événement
        public Builder location(String location) { event.location = location; return this; }
        // Définit la catégorie de l'événement
        public Builder category(Category category) { event.category = category; return this; }
        // Définit l'organisateur de l'événement
        public Builder organizer(User organizer) { event.organizer = organizer; return this; }
        // Construit et renvoie l'objet Event final
        public Event build() { return event; }
    }
}
