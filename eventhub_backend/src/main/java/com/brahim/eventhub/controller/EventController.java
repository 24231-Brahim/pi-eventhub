/*
 * FICHIER : EventController.java
 * RÔLE : Gère toutes les requêtes liées aux événements (CRUD complet)
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier est le "centre de commande" pour tout ce qui concerne les événements.
 * Il reçoit les requêtes de l'application mobile (liste, création, modification, suppression d'événements).
 * Chaque méthode est protégée par une authentification JWT (le token doit être envoyé dans le header).
 * Seul l'organisateur d'un événement peut le modifier ou le supprimer.
 * UTILISÉ PAR : L'application mobile via les routes /api/events/*
 */

package com.brahim.eventhub.controller;

import com.brahim.eventhub.dto.*;
import com.brahim.eventhub.service.EventService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * C'est un contrôleur REST (gère les requêtes HTTP)
 * Le chemin de base pour toutes les méthodes ici est "/api/events"
 * SecurityRequirement indique que toutes les routes nécessitent un token JWT valide
 */
@RestController
@RequestMapping("/api/events")
@Tag(name = "Events", description = "Event management endpoints")
@SecurityRequirement(name = "Bearer Authentication")
public class EventController {

    // Le service qui contient la logique métier pour les événements
    private final EventService eventService;

    // Constructeur : Spring injecte automatiquement le EventService ici
    public EventController(EventService eventService) {
        this.eventService = eventService;
    }

    /**
     * MÉTHODE : Récupérer tous les événements
     * ROUTE : GET /api/events
     * CE QUE ÇA FAIT :
     * 1. Récupère la liste de tous les événements disponibles
     * 2. Accessible par tous les utilisateurs connectés (organisateurs et invités)
     * 3. Retourne la liste des événements avec les détails de l'organisateur
     */
    @GetMapping
    @Operation(summary = "Get all events")
    public ResponseEntity<ApiResponse<List<EventResponse>>> getAllEvents() {
        List<EventResponse> events = eventService.getAllEvents();
        return ResponseEntity.ok(ApiResponse.success(events));
    }

    /**
     * MÉTHODE : Récupérer un événement par son identifiant
     * ROUTE : GET /api/events/{id}
     * CE QUE ÇA FAIT :
     * 1. Reçoit l'identifiant de l'événement dans l'URL
     * 2. Récupère les détails complets de l'événement
     * 3. Accessible par tous les utilisateurs connectés
     */
    @GetMapping("/{id}")
    @Operation(summary = "Get event by ID")
    public ResponseEntity<ApiResponse<EventResponse>> getEventById(@PathVariable Integer id) {
        EventResponse event = eventService.getEventById(id);
        return ResponseEntity.ok(ApiResponse.success(event));
    }

    /**
     * MÉTHODE : Créer un nouvel événement
     * ROUTE : POST /api/events
     * CE QUE ÇA FAIT :
     * 1. Reçoit les données du nouvel événement (titre, description, date, lieu, catégorie)
     * 2. Valide automatiquement les données (@Valid)
     * 3. Récupère l'email de l'utilisateur connecté (@AuthenticationPrincipal)
     * 4. Vérifie que l'utilisateur a le rôle ORGANIZER
     * 5. Crée l'événement et le sauvegarde en base
     */
    @PostMapping
    @Operation(summary = "Create a new event")
    public ResponseEntity<ApiResponse<EventResponse>> createEvent(
            @Valid @RequestBody EventRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        // userDetails.getUsername() renvoie l'email de l'utilisateur connecté
        EventResponse response = eventService.createEvent(request, userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Event created successfully", response));
    }

    /**
     * MÉTHODE : Modifier un événement existant
     * ROUTE : PUT /api/events/{id}
     * CE QUE ÇA FAIT :
     * 1. Reçoit l'identifiant de l'événement et les nouvelles données
     * 2. Valide les nouvelles données (@Valid)
     * 3. Vérifie que l'utilisateur connecté est bien l'organisateur de cet événement
     * 4. Met à jour les informations de l'événement en base
     */
    @PutMapping("/{id}")
    @Operation(summary = "Update an event")
    public ResponseEntity<ApiResponse<EventResponse>> updateEvent(
            @PathVariable Integer id,
            @Valid @RequestBody EventRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        EventResponse response = eventService.updateEvent(id, request, userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Event updated successfully", response));
    }

    /**
     * MÉTHODE : Supprimer un événement
     * ROUTE : DELETE /api/events/{id}
     * CE QUE ÇA FAIT :
     * 1. Reçoit l'identifiant de l'événement à supprimer
     * 2. Vérifie que l'utilisateur connecté est bien l'organisateur de cet événement
     * 3. Supprime l'événement de la base de données
     * 4. La suppression est définitive (cascade vers les invitations)
     */
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete an event")
    public ResponseEntity<ApiResponse<Void>> deleteEvent(
            @PathVariable Integer id,
            @AuthenticationPrincipal UserDetails userDetails) {
        eventService.deleteEvent(id, userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Event deleted successfully", null));
    }
}
