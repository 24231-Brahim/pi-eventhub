/*
 * FICHIER : CategoryService.java
 * RÔLE : Interface qui définit les opérations possibles sur les catégories
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier est une "liste de tâches" à accomplir.
 * Il dit quelles opérations on doit pouvoir faire sur les catégories (voir tout, créer).
 * C'est l'interface que la classe CategoryServiceImpl va implémenter.
 * UTILISÉ PAR : CategoryServiceImpl (qui fait le travail réel)
 */

package com.brahim.eventhub.service;

import com.brahim.eventhub.dto.CategoryRequest;
import com.brahim.eventhub.dto.CategoryResponse;

import java.util.List;

/**
 * Interface pour les opérations sur les catégories
 * Une interface définit "quoi faire" sans dire "comment le faire"
 */
public interface CategoryService {
    // Récupérer toutes les catégories
    List<CategoryResponse> getAllCategories();

    // Créer une nouvelle catégorie
    CategoryResponse createCategory(CategoryRequest request);
}
