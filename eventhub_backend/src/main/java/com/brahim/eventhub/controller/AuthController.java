/*
 * FICHIER : AuthController.java
 * RÔLE : Gère les requêtes d'authentification (inscription et connexion)
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier est comme un "guichet d'accueil" pour les utilisateurs.
 * Il reçoit les demandes d'inscription (register) et de connexion (login) venant de l'application mobile.
 * Quand un utilisateur s'inscrit ou se connecte, ce contrôleur appelle le service approprié
 * et renvoie une réponse avec un token JWT (clé d'accès) si tout se passe bien.
 * UTILISÉ PAR : Les applications mobiles (Flutter) via les routes /api/auth/register et /api/auth/login
 */

package com.brahim.eventhub.controller;

import com.brahim.eventhub.dto.*;
import com.brahim.eventhub.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * C'est un contrôleur REST (gère les requêtes HTTP)
 * Le chemin de base pour toutes les méthodes ici est "/api/auth"
 */
@RestController
@RequestMapping("/api/auth")
// Tag Swagger pour documenter cette section dans l'interface Swagger UI
@Tag(name = "Authentication", description = "User registration and login endpoints")
public class AuthController {

    // Le service qui contient la logique métier pour l'authentification
    private final AuthService authService;

    // Constructeur : Spring injecte automatiquement le AuthService ici
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * MÉTHODE : Inscrition d'un nouvel utilisateur
     * ROUTE : POST /api/auth/register
     * CE QUE ÇA FAIT :
     * 1. Reçoit les données d'inscription (nom, email, mot de passe, rôle)
     * 2. Valide automatiquement les données (@Valid)
     * 3. Appelle le service d'authentification pour créer l'utilisateur
     * 4. Renvoie un token JWT + les infos utilisateur si succès
     */
    @PostMapping("/register")
    @Operation(summary = "Register a new user")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        // Appelle le service pour inscrire l'utilisateur
        AuthResponse response = authService.register(request);
        // Renvoie une réponse HTTP 200 avec un message de succès et les données
        return ResponseEntity.ok(ApiResponse.success("User registered successfully", response));
    }

    /**
     * MÉTHODE : Connexion d'un utilisateur existant
     * ROUTE : POST /api/auth/login
     * CE QUE ÇA FAIT :
     * 1. Reçoit l'email et le mot de passe
     * 2. Valide automatiquement les données (@Valid)
     * 3. Vérifie les identifiants via le service d'authentification
     * 4. Si correct, renvoie un token JWT + les infos utilisateur
     * 5. Si incorrect, le service lancera une exception (gérée par GlobalExceptionHandler)
     */
    @PostMapping("/login")
    @Operation(summary = "Login user")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        // Appelle le service pour connecter l'utilisateur
        AuthResponse response = authService.login(request);
        // Renvoie une réponse HTTP 200 avec un message de succès et les données
        return ResponseEntity.ok(ApiResponse.success("Login successful", response));
    }
}
