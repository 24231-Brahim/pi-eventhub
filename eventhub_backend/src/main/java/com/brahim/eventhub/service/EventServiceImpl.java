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
 * Implementation of EventService for event operations.
 *
 * @author EventHub Team
 */
@Service
@Transactional
public class EventServiceImpl implements EventService {

    private final EventRepository eventRepository;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;

    public EventServiceImpl(EventRepository eventRepository, UserRepository userRepository,
                      CategoryRepository categoryRepository) {
        this.eventRepository = eventRepository;
        this.userRepository = userRepository;
        this.categoryRepository = categoryRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public List<EventResponse> getAllEvents() {
        return eventRepository.findAllWithOrganizer().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public EventResponse getEventById(Integer id) {
        Event event = eventRepository.findByIdWithDetails(id);
        if (event == null) {
            throw new ResourceNotFoundException("Event not found with id: " + id);
        }
        return toResponse(event);
    }

    @Override
    public EventResponse createEvent(EventRequest request, String organizerEmail) {
        User organizer = userRepository.findByEmail(organizerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Organizer not found"));

        if (organizer.getRole() != Role.ORGANIZER) {
            throw new AccessDeniedException("Only organizers can create events");
        }

        Event event = Event.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .date(request.getDate())
                .location(request.getLocation())
                .organizer(organizer)
                .build();

        if (request.getCategoryId() != null) {
            Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Category not found with id: " + request.getCategoryId()));
            event.setCategory(category);
        }

        event = eventRepository.save(event);
        return toResponse(event);
    }

    @Override
    public EventResponse updateEvent(Integer id, EventRequest request, String organizerEmail) {
        Event event = eventRepository.findByIdWithDetails(id);
        if (event == null) {
            throw new ResourceNotFoundException("Event not found with id: " + id);
        }

        if (!event.getOrganizer().getEmail().equals(organizerEmail)) {
            throw new AccessDeniedException("Only the organizer can update this event");
        }

        event.setTitle(request.getTitle());
        event.setDescription(request.getDescription());
        event.setDate(request.getDate());
        event.setLocation(request.getLocation());

        if (request.getCategoryId() != null) {
            Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Category not found with id: " + request.getCategoryId()));
            event.setCategory(category);
        } else {
            event.setCategory(null);
        }

        event = eventRepository.save(event);
        return toResponse(event);
    }

    @Override
    public void deleteEvent(Integer id, String organizerEmail) {
        Event event = eventRepository.findByIdWithDetails(id);
        if (event == null) {
            throw new ResourceNotFoundException("Event not found with id: " + id);
        }

        if (!event.getOrganizer().getEmail().equals(organizerEmail)) {
            throw new AccessDeniedException("Only the organizer can delete this event");
        }

        eventRepository.delete(event);
    }

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