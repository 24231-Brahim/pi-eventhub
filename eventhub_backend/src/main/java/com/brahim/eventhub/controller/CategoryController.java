/*
 * FICHIER : CategoryController.java
 * RÔLE : Gère les requêtes liées aux catégories d'événements
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier gère tout ce qui concerne les catégories.
 * Les catégories permettent de classer les événements (ex: Musique, Sport, Culture).
 * Ce contrôleur reçoit les demandes de liste des catégories ou de création d'une nouvelle catégorie.
 * UTILISÉ PAR : L'application mobile via les routes /api/categories/*
 */

package com.brahim.eventhub.controller;

import com.brahim.eventhub.dto.*;
import com.brahim.eventhub.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * C'est un contrôleur REST (gère les requêtes HTTP)
 * Le chemin de base pour toutes les méthodes ici est "/api/categories"
 */
@RestController
@RequestMapping("/api/categories")
@Tag(name = "Categories", description = "Event category management endpoints")
public class CategoryController {

    // Le service qui contient la logique métier pour les catégories
    private final CategoryService categoryService;

    // Constructeur : Spring injecte automatiquement le CategoryService ici
    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    /**
     * MÉTHODE : Récupérer toutes les catégories
     * ROUTE : GET /api/categories
     * CE QUE ÇA FAIT :
     * 1. Demande au service la liste de toutes les catégories disponibles
     * 2. Renvoie la liste au format JSON
     * NOTE : Cette route est publique (pas besoin de token JWT)
     */
    @GetMapping
    @Operation(summary = "Get all categories")
    public ResponseEntity<ApiResponse<List<CategoryResponse>>> getAllCategories() {
        List<CategoryResponse> categories = categoryService.getAllCategories();
        return ResponseEntity.ok(ApiResponse.success(categories));
    }

    /**
     * MÉTHODE : Créer une nouvelle catégorie
     * ROUTE : POST /api/categories
     * CE QUE ÇA FAIT :
     * 1. Reçoit le nom de la nouvelle catégorie
     * 2. Valide automatiquement les données (@Valid)
     * 3. Appelle le service pour créer la catégorie en base
     * 4. Renvoie la catégorie créée
     * NOTE : Cette route est publique (pas besoin de token JWT)
     */
    @PostMapping
    @Operation(summary = "Create a new category")
    public ResponseEntity<ApiResponse<CategoryResponse>> createCategory(
            @Valid @RequestBody CategoryRequest request) {
        CategoryResponse response = categoryService.createCategory(request);
        return ResponseEntity.ok(ApiResponse.success("Category created successfully", response));
    }
}
