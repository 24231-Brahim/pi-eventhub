/*
 * FICHIER : User.java
 * RÔLE : Définit le modèle de données pour les utilisateurs de l'application EventHub
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier décrit ce qu'est un utilisateur dans l'application.
 * Un utilisateur a un nom, un email unique, un mot de passe, et un rôle (organisateur ou invité).
 * Il peut organiser des événements, et recevoir des invitations à des événements.
 * Ce fichier est utilisé par tous les services qui gèrent les utilisateurs, les événements et les invitations.
 * UTILISÉ PAR : AuthService, EventService, InvitationService, UserRepository
 */

package com.brahim.eventhub.model;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

// Indique que cette classe est une entité JPA (liée à une table de base de données)
@Entity
// Indique que cette entité est liée à la table "users" de la base de données
@Table(name = "users")
public class User {

    // Identifiant unique de l'utilisateur (clé primaire)
    @Id
    // L'identifiant est généré automatiquement par la base de données (auto-incrément)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // Nom de l'utilisateur (ne peut pas être vide)
    @Column(nullable = false)
    private String name;

    // Email de l'utilisateur (ne peut pas être vide, doit être unique)
    @Column(nullable = false, unique = true)
    private String email;

    // Mot de passe de l'utilisateur (ne peut pas être vide, stocké de manière sécurisée)
    @Column(nullable = false)
    private String password;

    // Rôle de l'utilisateur (ORGANIZER ou GUEST, stocké sous forme de texte dans la base)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    // Liste des événements organisés par cet utilisateur (relation 1:N avec Event)
    @OneToMany(mappedBy = "organizer", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Event> organizedEvents = new ArrayList<>();

    // Liste des invitations reçues par cet utilisateur (relation 1:N avec Invitation)
    @OneToMany(mappedBy = "guest", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Invitation> invitations = new ArrayList<>();

    // Constructeur vide (obligatoire pour JPA)
    public User() {}

    // Getters et setters : permettent de lire et modifier les propriétés de l'utilisateur

    // Renvoie l'identifiant unique de l'utilisateur
    public Integer getId() { return id; }
    // Modifie l'identifiant de l'utilisateur
    public void setId(Integer id) { this.id = id; }

    // Renvoie le nom de l'utilisateur
    public String getName() { return name; }
    // Modifie le nom de l'utilisateur
    public void setName(String name) { this.name = name; }

    // Renvoie l'email de l'utilisateur
    public String getEmail() { return email; }
    // Modifie l'email de l'utilisateur
    public void setEmail(String email) { this.email = email; }

    // Renvoie le mot de passe de l'utilisateur (attention : jamais affiché en clair)
    public String getPassword() { return password; }
    // Modifie le mot de passe de l'utilisateur (sera hashé avant stockage en base)
    public void setPassword(String password) { this.password = password; }

    // Renvoie le rôle de l'utilisateur (ORGANIZER ou GUEST)
    public Role getRole() { return role; }
    // Modifie le rôle de l'utilisateur
    public void setRole(Role role) { this.role = role; }

    // Renvoie la liste des événements organisés par l'utilisateur
    public List<Event> getOrganizedEvents() { return organizedEvents; }
    // Modifie la liste des événements organisés par l'utilisateur
    public void setOrganizedEvents(List<Event> organizedEvents) { this.organizedEvents = organizedEvents; }

    // Renvoie la liste des invitations reçues par l'utilisateur
    public List<Invitation> getInvitations() { return invitations; }
    // Modifie la liste des invitations reçues par l'utilisateur
    public void setInvitations(List<Invitation> invitations) { this.invitations = invitations; }

    // Pattern Builder : permet de créer un objet User étape par étape
    public static Builder builder() { return new Builder(); }

    // Classe interne Builder pour construire un objet User facilement
    public static class Builder {
        private final User user = new User();

        // Définit l'identifiant de l'utilisateur à construire
        public Builder id(Integer id) { user.id = id; return this; }
        // Définit le nom de l'utilisateur à construire
        public Builder name(String name) { user.name = name; return this; }
        // Définit l'email de l'utilisateur à construire
        public Builder email(String email) { user.email = email; return this; }
        // Définit le mot de passe de l'utilisateur à construire
        public Builder password(String password) { user.password = password; return this; }
        // Définit le rôle de l'utilisateur à construire
        public Builder role(Role role) { user.role = role; return this; }
        // Construit et renvoie l'objet User final
        public User build() { return user; }
    }

    // Vérifie si l'utilisateur a le rôle ORGANIZER (organisateur)
    public boolean isOrganizer() {
        return role == Role.ORGANIZER;
    }
}
