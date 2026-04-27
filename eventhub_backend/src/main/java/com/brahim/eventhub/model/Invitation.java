/*
 * FICHIER : Invitation.java
 * RÔLE : Définit le modèle de données pour les invitations à un événement
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier décrit ce qu'est une invitation dans l'application EventHub.
 * Une invitation lie un événement à un invité (utilisateur avec rôle GUEST).
 * Elle contient un code QR unique (généré automatiquement) et un statut (EN_ATTENTE ou UTILISÉ).
 * L'organisateur envoie une invitation à un invité, qui peut ensuite afficher son QR code.
 * Lors de l'événement, l'organisateur scanne le QR pour vérifier l'invitation (statut passe à UTILISÉ).
 * UTILISÉ PAR : InvitationService, InvitationController, InvitationRepository, EventService
 */

package com.brahim.eventhub.model;

import jakarta.persistence.*;
import java.util.UUID;

// Indique que cette classe est une entité JPA liée à la table "invitations"
@Entity
@Table(name = "invitations")
public class Invitation {

    // Identifiant unique de l'invitation (clé primaire, auto-généré)
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // L'événement concerné par cette invitation - relation N:1 vers Event
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "event_id", nullable = false)
    private Event event;

    // L'invité (utilisateur avec rôle GUEST) - relation N:1 vers User
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "guest_id", nullable = false)
    private User guest;

    // Statut de l'invitation (PENDING=en attente, USED=déjà utilisé)
    // Par défaut, une nouvelle invitation est en attente (PENDING)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private InvitationStatus status = InvitationStatus.PENDING;

    // Code QR unique de l'invitation (une chaîne UUID générée automatiquement)
    // Ce code sera transformé en QR code visuel pour l'invité
    @Column(nullable = false, unique = true)
    private String qrCode;

    // Constructeur vide (obligatoire pour JPA/Hibernate)
    public Invitation() {}

    // Cette méthode est appelée automatiquement avant la première sauvegarde en base
    // Elle génère un code QR unique (UUID) si ce n'est pas déjà fait
    @PrePersist
    public void prePersist() {
        if (qrCode == null) {
            qrCode = UUID.randomUUID().toString();
        }
    }

    // Getters et setters : permettent de lire et modifier les propriétés de l'invitation

    // Renvoie l'identifiant unique de l'invitation
    public Integer getId() { return id; }
    // Modifie l'identifiant de l'invitation
    public void setId(Integer id) { this.id = id; }

    // Renvoie l'événement lié à cette invitation
    public Event getEvent() { return event; }
    // Modifie l'événement lié à cette invitation
    public void setEvent(Event event) { this.event = event; }

    // Renvoie l'invité (utilisateur) concerné par cette invitation
    public User getGuest() { return guest; }
    // Modifie l'invité concerné par cette invitation
    public void setGuest(User guest) { this.guest = guest; }

    // Renvoie le statut de l'invitation (PENDING ou USED)
    public InvitationStatus getStatus() { return status; }
    // Modifie le statut de l'invitation (ex: passer de PENDING à USED)
    public void setStatus(InvitationStatus status) { this.status = status; }

    // Renvoie le code QR (chaîne UUID) de l'invitation
    public String getQrCode() { return qrCode; }
    // Modifie le code QR de l'invitation (généralement fait automatiquement)
    public void setQrCode(String qrCode) { this.qrCode = qrCode; }

    // Pattern Builder : permet de créer une invitation étape par étape
    public static Builder builder() { return new Builder(); }

    // Classe interne Builder pour construire une invitation facilement
    public static class Builder {
        private final Invitation invitation = new Invitation();

        // Définit l'identifiant de l'invitation
        public Builder id(Integer id) { invitation.id = id; return this; }
        // Définit l'événement de l'invitation
        public Builder event(Event event) { invitation.event = event; return this; }
        // Définit l'invité de l'invitation
        public Builder guest(User guest) { invitation.guest = guest; return this; }
        // Définit le statut de l'invitation
        public Builder status(InvitationStatus status) { invitation.status = status; return this; }
        // Définit le code QR de l'invitation
        public Builder qrCode(String qrCode) { invitation.qrCode = qrCode; return this; }
        // Construit et renvoie l'objet Invitation final
        public Invitation build() { return invitation; }
    }

    // Vérifie si l'invitation est encore en attente (pas encore utilisée)
    public boolean isPending() {
        return status == InvitationStatus.PENDING;
    }
}
