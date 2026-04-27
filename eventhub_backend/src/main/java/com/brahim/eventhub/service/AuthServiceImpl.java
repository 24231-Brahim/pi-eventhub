/*
 * FICHIER : AuthServiceImpl.java
 * RÔLE : Contient toute la logique métier pour l'inscription et la connexion
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier fait le travail réel d'authentification.
 * Quand un utilisateur s'inscrit, on vérifie que son email n'est pas déjà utilisé,
 * on code son mot de passe (pour qu'il ne soit pas lisible en base), et on crée son compte.
 * Quand il se connecte, on vérifie ses identifiants et on lui donne un "laissez-passer" (token JWT).
 * UTILISÉ PAR : AuthController qui reçoit les requêtes HTTP
 */

package com.brahim.eventhub.service;

import com.brahim.eventhub.dto.AuthResponse;
import com.brahim.eventhub.dto.LoginRequest;
import com.brahim.eventhub.dto.RegisterRequest;
import com.brahim.eventhub.exception.AuthenticationException;
import com.brahim.eventhub.exception.EmailAlreadyExistsException;
import com.brahim.eventhub.model.Role;
import com.brahim.eventhub.model.User;
import com.brahim.eventhub.repository.UserRepository;
import com.brahim.eventhub.security.JwtService;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Collections;

/**
 * Implémentation de l'interface AuthService
 * @Service indique à Spring que c'est un composant métier
 */
@Service
public class AuthServiceImpl implements AuthService {

    // Accès à la base de données pour les utilisateurs
    private final UserRepository userRepository;
    // Outil pour coder les mots de passe (BCrypt - irreversible)
    private final PasswordEncoder passwordEncoder;
    // Outil pour créer et valider les tokens JWT
    private final JwtService jwtService;
    // Gestionnaire d'authentification de Spring Security
    private final AuthenticationManager authenticationManager;

    // Constructeur avec injection de dépendances (Spring remplit automatiquement)
    public AuthServiceImpl(UserRepository userRepository, PasswordEncoder passwordEncoder,
                          JwtService jwtService, AuthenticationManager authenticationManager) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
    }

    /**
     * MÉTHODE : Inscrition d'un nouvel utilisateur
     * CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
     * 1. Vérifie si l'email est déjà utilisé dans la base de données
     * 2. Si oui, lance une erreur "Email déjà enregistré"
     * 3. Vérifie que le rôle est valide (ORGANIZER ou GUEST)
     * 4. Crée un nouvel utilisateur avec les informations fournies
     * 5. Code le mot de passe avec BCrypt (il ne sera plus lisible)
     * 6. Sauvegarde l'utilisateur dans la base de données
     * 7. Crée un "UserDetails" pour que JWT puisse générer un token
     * 8. Génère un token JWT qui servira de clé d'accès
     * 9. Renvoie les informations de l'utilisateur + le token
     */
    @Override
    public AuthResponse register(RegisterRequest request) {
        // Étape 1 : Vérifier si l'email existe déjà
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new EmailAlreadyExistsException("Email already registered: " + request.getEmail());
        }

        // Étape 2 : Convertir le rôle texte en enum Role (ORGANIZER ou GUEST)
        Role role;
        try {
            role = Role.valueOf(request.getRole().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new AuthenticationException("Invalid role. Must be ORGANIZER or GUEST");
        }

        // Étape 3 : Créer le nouvel utilisateur avec les données fournies
        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                // Le mot de passe est codé (haché) - impossible à lire en clair
                .password(passwordEncoder.encode(request.getPassword()))
                .role(role)
                .build();

        // Étape 4 : Sauvegarder l'utilisateur dans la base de données
        userRepository.save(user);

        // Étape 5 : Créer un objet UserDetails pour le JWT
        // C'est le format que Spring Security comprend pour générer le token
        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPassword(),
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + user.getRole().name()))
        );

        // Étape 6 : Générer le token JWT avec les informations de l'utilisateur
        String token = jwtService.generateToken(userDetails);

        // Étape 7 : Construire et renvoyer la réponse avec token + infos utilisateur
        return AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .name(user.getName())
                .role(user.getRole().name())
                .build();
    }

    /**
     * MÉTHODE : Connexion d'un utilisateur existant
     * CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
     * 1. Demande à Spring Security de vérifier l'email et le mot de passe
     * 2. Si les identifiants sont incorrects, lance une erreur
     * 3. Récupère les informations complètes de l'utilisateur
     * 4. Crée un "UserDetails" pour le JWT
     * 5. Génère un nouveau token JWT
     * 6. Renvoie les informations de l'utilisateur + le token
     */
    @Override
    public AuthResponse login(LoginRequest request) {
        try {
            // Étape 1 : Spring Security vérifie si l'email et le mot de passe correspondent
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );
        } catch (BadCredentialsException e) {
            // Si les identifiants sont faux, on lance une erreur
            throw new AuthenticationException("Invalid email or password");
        }

        // Étape 2 : Récupérer l'utilisateur complet depuis la base
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new AuthenticationException("User not found"));

        // Étape 3 : Créer le UserDetails pour le JWT
        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPassword(),
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + user.getRole().name()))
        );

        // Étape 4 : Générer le token JWT
        String token = jwtService.generateToken(userDetails);

        // Étape 5 : Construire et renvoyer la réponse
        return AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .name(user.getName())
                .role(user.getRole().name())
                .build();
    }
}
