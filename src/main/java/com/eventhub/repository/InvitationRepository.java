package com.eventhub.repository;

import com.eventhub.model.Invitation;
import com.eventhub.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InvitationRepository extends JpaRepository<Invitation, Long> {
    List<Invitation> findByGuest(User guest);
    Optional<Invitation> findByQrCode(String qrCode);
}
