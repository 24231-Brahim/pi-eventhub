/*
 * FICHIER : EventServiceImpl.java
 * RÔLE : Contient toute la logique métier pour la gestion des événements
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier fait le vrai travail quand on veut gérer les événements.
 * Il vérifie les permissions (seul l'organisateur peut modifier son événement),
 * récupère les données de la base, crée ou modifie les événements,
 * et convertit les données brutes en format lisible (DTO).
 * UTILISÉ PAR : EventController qui reçoit les requêtes HTTP
 */

package com.brahim.eventhub.service;

import com.brahim.eventhub.dto.EventRequest;
import com.brahim.eventhub.dto.EventResponse;
import com.brahim.eventhub.exception.AccessDeniedException;
import com.brahim.eventhub.exception.ResourceNotFoundException;
import com.brahim.eventhub.model.Category;
import com.brahim.eventhub.model.Event;
import com.brahim.eventhub.model.Role;
import com.brahim.eventhub.model.User;
import com.brahim.eventhub.repository.CategoryRepository;
import com.brahim.eventhub.repository.EventRepository;
import com.brahim.eventhub.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Implémentation de l'interface EventService
 * @Service indique à Spring que c'est un composant métier
 * @Transactional garantit que toutes les opérations sur la base sont sécurisées
 */
@Service
@Transactional
public class EventServiceImpl implements EventService {

    // Accès à la table des événements en base
    private final EventRepository eventRepository;
    // Accès à la table des utilisateurs en base
    private final UserRepository userRepository;
    // Accès à la table des catégories en base
    private final CategoryRepository categoryRepository;

    // Constructeur avec injection de dépendances (Spring remplit automatiquement)
    public EventServiceImpl(EventRepository eventRepository, UserRepository userRepository,
                       CategoryRepository categoryRepository) {
        this.eventRepository = eventRepository;
        this.userRepository = userRepository;
        this.categoryRepository = categoryRepository;
    }

    /**
     * MÉTHODE : Récupérer tous les événements
     * CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
     * 1. Demande à la base de données tous les événements avec les infos de l'organisateur
     * 2. Convertit chaque événement en format de réponse (EventResponse)
     * 3. Renvoie la liste complète
     * NOTE : Cette méthode est en lecture seule (@Transactional(readOnly = true))
     */
    @Override
    @Transactional(readOnly = true)
    public List<EventResponse> getAllEvents() {
        return eventRepository.findAllWithOrganizer().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * MÉTHODE : Récupérer un événement par son identifiant
     * CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
     * 1. Cherche l'événement avec ses détails (organisateur, catégorie)
     * 2. Si l'événement n'existe pas, lance une erreur "Événement non trouvé"
     * 3. Convertit en format de réponse et renvoie
     */
    @Override
    @Transactional(readOnly = true)
    public EventResponse getEventById(Integer id) {
        Event event = eventRepository.findByIdWithDetails(id);
        if (event == null) {
            throw new ResourceNotFoundException("Event not found with id: " + id);
        }
        return toResponse(event);
    }

    /**
     * MÉTHODE : Créer un nouvel événement
     * CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
     * 1. Récupère l'organisateur via son email
     * 2. Vérifie que l'utilisateur a bien le rôle ORGANIZER
     * 3. Crée un nouvel objet Event avec les données fournies
     * 4. Si une catégorie est spécifiée, on la lie à l'événement
     * 5. Sauvegarde l'événement dans la base de données
     * 6. Renvoie l'événement créé
     */
    @Override
    public EventResponse createEvent(EventRequest request, String organizerEmail) {
        // Étape 1 : Trouver l'organisateur par son email
        User organizer = userRepository.findByEmail(organizerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Organizer not found"));

        // Étape 2 : Vérifier que c'est bien un organisateur
        if (organizer.getRole() != Role.ORGANIZER) {
            throw new AccessDeniedException("Only organizers can create events");
        }

        // Étape 3 : Construire le nouvel événement
        Event event = Event.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .date(request.getDate())
                .location(request.getLocation())
                .organizer(organizer)
                .build();

        // Étape 4 : Lier la catégorie si elle est spécifiée
        if (request.getCategoryId() != null) {
            Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Category not found with id: " + request.getCategoryId()));
            event.setCategory(category);
        }

        // Étape 5 : Sauvegarder en base
        event = eventRepository.save(event);
        // Étape 6 : Renvoyer la réponse
        return toResponse(event);
    }

    /**
     * MÉTHODE : Modifier un événement existant
     * CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
     * 1. Cherche l'événement à modifier
     * 2. Vérifie que l'utilisateur est bien l'organisateur de cet événement
     * 3. Met à jour les champs (titre, description, date, lieu)
     * 4. Met à jour ou supprime la catégorie
     * 5. Sauvegarde les modifications en base
     */
    @Override
    public EventResponse updateEvent(Integer id, EventRequest request, String organizerEmail) {
        // Étape 1 : Trouver l'événement
        Event event = eventRepository.findByIdWithDetails(id);
        if (event == null) {
            throw new ResourceNotFoundException("Event not found with id: " + id);
        }

        // Étape 2 : Vérifier que c'est le propriétaire
        if (!event.getOrganizer().getEmail().equals(organizerEmail)) {
            throw new AccessDeniedException("Only the organizer can update this event");
        }

        // Étape 3 : Mettre à jour les champs
        event.setTitle(request.getTitle());
        event.setDescription(request.getDescription());
        event.setDate(request.getDate());
        event.setLocation(request.getLocation());

        // Étape 4 : Gérer la catégorie
        if (request.getCategoryId() != null) {
            Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Category not found with id: " + request.getCategoryId()));
            event.setCategory(category);
        } else {
            event.setCategory(null);
        }

        // Étape 5 : Sauvegarder
        event = eventRepository.save(event);
        return toResponse(event);
    }

    /**
     * MÉTHODE : Supprimer un événement
     * CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
     * 1. Cherche l'événement à supprimer
     * 2. Vérifie que l'utilisateur est bien le propriétaire
     * 3. Supprime l'événement (et ses invitations par cascade)
     */
    @Override
    public void deleteEvent(Integer id, String organizerEmail) {
        // Étape 1 : Trouver l'événement
        Event event = eventRepository.findByIdWithDetails(id);
        if (event == null) {
            throw new ResourceNotFoundException("Event not found with id: " + id);
        }

        // Étape 2 : Vérifier que c'est le propriétaire
        if (!event.getOrganizer().getEmail().equals(organizerEmail)) {
            throw new AccessDeniedException("Only the organizer can delete this event");
        }

        // Étape 3 : Supprimer
        eventRepository.delete(event);
    }

    /**
     * MÉTHODE PRIVÉE : Convertir un Event en EventResponse
     * CE QUE ÇA FAIT : Transforme l'entité brute de la base en un objet lisible
     * avec seulement les informations nécessaires pour l'application mobile
     */
    private EventResponse toResponse(Event event) {
        return EventResponse.builder()
                .id(event.getId())
                .title(event.getTitle())
                .description(event.getDescription())
                .date(event.getDate())
                .location(event.getLocation())
                .categoryName(event.getCategory() != null ? event.getCategory().getName() : null)
                .organizerName(event.getOrganizer().getName())
                .organizerEmail(event.getOrganizer().getEmail())
                .build();
    }
}
