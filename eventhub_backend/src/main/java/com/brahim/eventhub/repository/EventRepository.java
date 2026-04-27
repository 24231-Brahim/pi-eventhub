package com.brahim.eventhub.repository;

import com.brahim.eventhub.model.Event;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository interface for Event entity operations.
 *
 * @author EventHub Team
 */
@Repository
public interface EventRepository extends JpaRepository<Event, Integer> {
    List<Event> findByOrganizerId(Integer organizerId);

    @Query("SELECT e FROM Event e JOIN FETCH e.organizer ORDER BY e.date DESC")
    List<Event> findAllWithOrganizer();

    @Query("SELECT e FROM Event e LEFT JOIN FETCH e.category LEFT JOIN FETCH e.organizer WHERE e.id = :id")
    Event findByIdWithDetails(@Param("id") Integer id);
}