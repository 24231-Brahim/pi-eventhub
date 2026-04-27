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
 * REST controller for event endpoints.
 *
 * @author EventHub Team
 */
@RestController
@RequestMapping("/api/events")
@Tag(name = "Events", description = "Event management endpoints")
@SecurityRequirement(name = "Bearer Authentication")
public class EventController {

    private final EventService eventService;

    public EventController(EventService eventService) {
        this.eventService = eventService;
    }

    @GetMapping
    @Operation(summary = "Get all events")
    public ResponseEntity<ApiResponse<List<EventResponse>>> getAllEvents() {
        List<EventResponse> events = eventService.getAllEvents();
        return ResponseEntity.ok(ApiResponse.success(events));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get event by ID")
    public ResponseEntity<ApiResponse<EventResponse>> getEventById(@PathVariable Integer id) {
        EventResponse event = eventService.getEventById(id);
        return ResponseEntity.ok(ApiResponse.success(event));
    }

    @PostMapping
    @Operation(summary = "Create a new event")
    public ResponseEntity<ApiResponse<EventResponse>> createEvent(
            @Valid @RequestBody EventRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        EventResponse response = eventService.createEvent(request, userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Event created successfully", response));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an event")
    public ResponseEntity<ApiResponse<EventResponse>> updateEvent(
            @PathVariable Integer id,
            @Valid @RequestBody EventRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        EventResponse response = eventService.updateEvent(id, request, userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Event updated successfully", response));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete an event")
    public ResponseEntity<ApiResponse<Void>> deleteEvent(
            @PathVariable Integer id,
            @AuthenticationPrincipal UserDetails userDetails) {
        eventService.deleteEvent(id, userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Event deleted successfully", null));
    }
}