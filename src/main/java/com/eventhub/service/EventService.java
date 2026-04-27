package com.eventhub.service;

import com.eventhub.dto.EventRequest;
import com.eventhub.dto.EventResponse;
import com.eventhub.model.Category;
import com.eventhub.model.Event;
import com.eventhub.model.User;
import com.eventhub.repository.CategoryRepository;
import com.eventhub.repository.EventRepository;
import com.eventhub.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EventService {

    private final EventRepository eventRepository;
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;

    public List<EventResponse> getAllEvents() {
        return eventRepository.findAll()
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public EventResponse getEventById(Long id) {
        Event event = findEventOrThrow(id);
        return toResponse(event);
    }

    public EventResponse createEvent(EventRequest request, String organizerEmail) {
        User organizer = findUserOrThrow(organizerEmail);
        Category category = resolveCategory(request.getCategoryId());

        Event event = Event.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .date(request.getDate())
                .location(request.getLocation())
                .category(category)
                .organizer(organizer)
                .build();

        return toResponse(eventRepository.save(event));
    }

    public EventResponse updateEvent(Long id, EventRequest request, String organizerEmail) {
        Event event = findEventOrThrow(id);

        // Only the owning organizer can update
        if (!event.getOrganizer().getEmail().equals(organizerEmail)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not the organizer of this event");
        }

        Category category = resolveCategory(request.getCategoryId());

        event.setTitle(request.getTitle());
        event.setDescription(request.getDescription());
        event.setDate(request.getDate());
        event.setLocation(request.getLocation());
        event.setCategory(category);

        return toResponse(eventRepository.save(event));
    }

    public void deleteEvent(Long id, String organizerEmail) {
        Event event = findEventOrThrow(id);

        if (!event.getOrganizer().getEmail().equals(organizerEmail)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not the organizer of this event");
        }

        eventRepository.delete(event);
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private Event findEventOrThrow(Long id) {
        return eventRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Event not found with id: " + id));
    }

    private User findUserOrThrow(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }

    private Category resolveCategory(Long categoryId) {
        if (categoryId == null) return null;
        return categoryRepository.findById(categoryId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found with id: " + categoryId));
    }

    public EventResponse toResponse(Event event) {
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
