package com.brahim.eventhub.service;

import com.brahim.eventhub.dto.EventRequest;
import com.brahim.eventhub.dto.EventResponse;

import java.util.List;

/**
 * Service interface for event operations.
 *
 * @author EventHub Team
 */
public interface EventService {
    List<EventResponse> getAllEvents();
    EventResponse getEventById(Integer id);
    EventResponse createEvent(EventRequest request, String organizerEmail);
    EventResponse updateEvent(Integer id, EventRequest request, String organizerEmail);
    void deleteEvent(Integer id, String organizerEmail);
}