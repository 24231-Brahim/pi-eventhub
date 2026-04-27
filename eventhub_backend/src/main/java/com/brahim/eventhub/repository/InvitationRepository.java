package com.brahim.eventhub.repository;

import com.brahim.eventhub.model.Invitation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository interface for Invitation entity operations.
 *
 * @author EventHub Team
 */
@Repository
public interface InvitationRepository extends JpaRepository<Invitation, Integer> {
    List<Invitation> findByGuestId(Integer guestId);

    Optional<Invitation> findByQrCode(String qrCode);

    @Query("SELECT i FROM Invitation i JOIN FETCH i.event JOIN FETCH i.guest WHERE i.guest.id = :guestId")
    List<Invitation> findByGuestIdWithDetails(@Param("guestId") Integer guestId);

    boolean existsByEventIdAndGuestId(Integer eventId, Integer guestId);
}