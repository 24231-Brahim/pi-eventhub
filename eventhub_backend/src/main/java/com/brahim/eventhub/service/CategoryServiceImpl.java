/*
 * FICHIER : CategoryServiceImpl.java
 * RÔLE : Contient la logique métier pour les catégories
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier fait le vrai travail pour les catégories.
 * Il vérifie si une catégorie existe déjà avant de la créer,
 * récupère toutes les catégories de la base, et convertit les données en format lisible.
 * UTILISÉ PAR : CategoryController qui reçoit les requêtes HTTP
 */

package com.brahim.eventhub.service;

import com.brahim.eventhub.dto.CategoryRequest;
import com.brahim.eventhub.dto.CategoryResponse;
import com.brahim.eventhub.exception.ResourceAlreadyExistsException;
import com.brahim.eventhub.model.Category;
import com.brahim.eventhub.repository.CategoryRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Implémentation de l'interface CategoryService
 * @Service indique à Spring que c'est un composant métier
 */
@Service
public class CategoryServiceImpl implements CategoryService {

    // Accès à la table des catégories en base
    private final CategoryRepository categoryRepository;

    // Constructeur avec injection de dépendances
    public CategoryServiceImpl(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    /**
     * MÉTHODE : Récupérer toutes les catégories
     * CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
     * 1. Demande à la base de données toutes les catégories
     * 2. Convertit chaque catégorie en format de réponse (CategoryResponse)
     * 3. Renvoie la liste complète
     */
    @Override
    public List<CategoryResponse> getAllCategories() {
        return categoryRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * MÉTHODE : Créer une nouvelle catégorie
     * CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
     * 1. Vérifie si une catégorie avec ce nom existe déjà
     * 2. Si oui, lance une erreur "Catégorie déjà existante"
     * 3. Crée une nouvelle catégorie avec le nom fourni
     * 4. Sauvegarde en base de données
     * 5. Renvoie la catégorie créée
     */
    @Override
    public CategoryResponse createCategory(CategoryRequest request) {
        // Étape 1 et 2 : Vérifier si le nom existe déjà
        if (categoryRepository.existsByName(request.getName())) {
            throw new ResourceAlreadyExistsException("Category already exists: " + request.getName());
        }

        // Étape 3 : Construire la nouvelle catégorie
        Category category = Category.builder()
                .name(request.getName())
                .build();

        // Étape 4 : Sauvegarder en base
        category = categoryRepository.save(category);
        // Étape 5 : Renvoyer la réponse
        return toResponse(category);
    }

    /**
     * MÉTHODE PRIVÉE : Convertir une Category en CategoryResponse
     * CE QUE ÇA FAIT : Transforme l'entité brute de la base en un objet lisible
     */
    private CategoryResponse toResponse(Category category) {
        return CategoryResponse.builder()
                .id(category.getId())
                .name(category.getName())
                .build();
    }
}
