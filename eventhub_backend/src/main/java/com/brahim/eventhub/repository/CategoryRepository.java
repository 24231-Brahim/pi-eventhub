package com.brahim.eventhub.repository;

import com.brahim.eventhub.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository interface for Category entity operations.
 *
 * @author EventHub Team
 */
@Repository
public interface CategoryRepository extends JpaRepository<Category, Integer> {
    Optional<Category> findByName(String name);
    boolean existsByName(String name);
}