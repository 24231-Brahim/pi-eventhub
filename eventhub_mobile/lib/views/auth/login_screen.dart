/*
 * FICHIER : login_screen.dart
 * RÔLE : Affiche l'écran de connexion et d'inscription (Login + Register)
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier contient deux écrans dans un seul fichier.
 * 1. LoginScreen : Permet à un utilisateur existant de se connecter (email + mot de passe)
 * 2. RegisterScreen : Permet de créer un nouveau compte (nom, email, mot de passe, rôle)
 * Il y a aussi des widgets partagés : _InputField (champ de saisie) et _LanguageToggle (changement de langue)
 * UTILISÉ PAR : main.dart (première page affichée au démarrage)
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import 'package:eventhub_app/l10n/app_localizations.dart';
import 'register_screen.dart'; // (redirige vers le même fichier, c'est juste pour la navigation)
import '../events/events_list_screen.dart';

// ── ÉCRAN DE CONNEXION ────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin { // Pour l'animation de fondu
  // Clé du formulaire (pour valider les champs)
  final _formKey = GlobalKey<FormState>();
  // Contrôleurs pour récupérer le texte saisi dans les champs
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  // Indique si le mot de passe est masqué (true = points noirs)
  bool _obscure = true;
  // Contrôleur d'animation (pour l'effet de fondu à l'apparition)
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    // Initialise l'animation (durée 900 millisecondes)
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    // Courbe d'animation (début lent, fin rapide)
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward(); // Lance l'animation
  }

  @override
  void dispose() {
    // Nettoie les contrôleurs et l'animation pour éviter les fuites mémoire
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // MÉTHODE : Tenter la connexion
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Vérifie que le formulaire est valide (email + mot de passe corrects)
  // 2. Appelle le AuthProvider pour connecter l'utilisateur
  // 3. Si succès : redirige vers la page d'accueil (liste des événements)
  // 4. Si échec : affiche un message d'erreur (SnackBar rouge)
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return; // Si formulaire invalide, on arrête
    final auth = context.read<AuthProvider>(); // Récupère le provider d'authentification
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return; // Vérifie si le widget est encore affiché
    if (ok) {
      // Connexion réussie : on va à la page d'accueil et on vire la page de connexion de l'historique
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const EventsListScreen()));
    } else {
      // Échec : on affiche l'erreur en bas de l'écran
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error ?? 'Login failed'),
              backgroundColor: Colors.red.shade700));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!; // Traductions
    final lang = context.read<LanguageProvider>(); // Gestionnaire de langue
    final auth = context.watch<AuthProvider>(); // État d'authentification (pour le chargement)
    final theme = Theme.of(context); // Thème de l'application

    return Scaffold(
      body: Container(
        // Fond dégradé (du indigo au violet foncé)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              const Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim, // Animation de fondu
              child: SingleChildScrollView( // Permet de scroller si le clavier apparaît
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bouton de changement de langue (en haut à droite)
                    Align(
                      alignment: Alignment.topRight,
                      child: _LanguageToggle(lang: lang, l: l),
                    ),
                    const SizedBox(height: 20),
                    // Logo de l'application (icône d'événement)
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 2),
                      ),
                      child: const Icon(Icons.event_available,
                          size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    // Titre de l'application
                    Text(l.appTitle,
                        style: theme.textTheme.headlineMedium!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 36),
                    // Carte blanche contenant le formulaire
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      elevation: 10, // Ombre portée
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Titre "Connexion"
                              Text(l.login,
                                  style: theme.textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              // Champ Email
                              _InputField(
                                controller: _emailCtrl,
                                label: l.email,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return l.fieldRequired;
                                  if (!v.contains('@')) return l.invalidEmail;
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Champ Mot de passe
                              _InputField(
                                controller: _passCtrl,
                                label: l.password,
                                icon: Icons.lock_outline,
                                obscure: _obscure, // Masqué par défaut
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure), // Affiche/masque le mot de passe
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return l.fieldRequired;
                                  if (v.length < 6) return l.passwordMin;
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),
                              // Bouton de connexion
                              ElevatedButton(
                                onPressed: auth.loading ? null : _login, // Désactivé si chargement en cours
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: auth.loading
                                    ? const SizedBox(
                                        height: 20, width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.white))
                                    : Text(l.login,
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Lien vers l'inscription
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l.noAccount,
                            style: const TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen())),
                          child: Text(l.register,
                              style: const TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── ÉCRAN D'INSCRIPTION ────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Clé du formulaire
  final _formKey = GlobalKey<FormState>();
  // Contrôleurs pour les champs
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  // Rôle choisi (par défaut : GUEST)
  String _role = 'GUEST';
  // Indique si le mot de passe est masqué
  bool _obscure = true;

  @override
  void dispose() {
    // Nettoie les contrôleurs
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // MÉTHODE : Créer un nouveau compte
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Vérifie que le formulaire est valide
  // 2. Appelle le AuthProvider pour inscrire l'utilisateur
  // 3. Si succès : va à la page d'accueil et vide tout l'historique
  // 4. Si échec : affiche un message d'erreur
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
        _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text, _role);
    if (!mounted) return;
    if (ok) {
      // Inscription réussie : on va à la page d'accueil et on vide l'historique
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const EventsListScreen()),
          (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(auth.error ?? 'Register failed'),
          backgroundColor: Colors.red.shade700));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        // Fond dégradé
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              const Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Bouton retour
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Logo inscription
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Icon(Icons.person_add,
                        size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(l.appTitle,
                      style: theme.textTheme.headlineSmall!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 28),
                  // Carte blanche formulaire
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(l.register,
                                style: theme.textTheme.titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            // Champ Nom
                            _InputField(
                              controller: _nameCtrl,
                              label: l.name,
                              icon: Icons.person_outline,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? l.fieldRequired
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            // Champ Email
                            _InputField(
                              controller: _emailCtrl,
                              label: l.email,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return l.fieldRequired;
                                if (!v.contains('@')) return l.invalidEmail;
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            // Champ Mot de passe
                            _InputField(
                              controller: _passCtrl,
                              label: l.password,
                              icon: Icons.lock_outline,
                              obscure: _obscure,
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return l.fieldRequired;
                                if (v.length < 6) return l.passwordMin;
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            // Sélecteur de rôle (GUEST ou ORGANIZER)
                            DropdownButtonFormField<String>(
                              value: _role,
                              decoration: InputDecoration(
                                labelText: l.role,
                                prefixIcon: const Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              items: [
                                DropdownMenuItem(
                                    value: 'GUEST', child: Text(l.guest)),
                                DropdownMenuItem(
                                    value: 'ORGANIZER', child: Text(l.organizer)),
                              ],
                              onChanged: (v) =>
                                  setState(() => _role = v ?? 'GUEST'),
                            ),
                            const SizedBox(height: 24),
                            // Bouton Inscription
                            ElevatedButton(
                              onPressed: auth.loading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: auth.loading
                                  ? const SizedBox(
                                      height: 20, width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : Text(l.register,
                                      style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Lien vers la connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.haveAccount,
                          style: const TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l.login,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── WIDGETS PARTAGÉS ───────────────────────────────────────────────────

// Widget réutilisable pour les champs de saisie
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

// Widget pour basculer entre les langues (FR/AR)
class _LanguageToggle extends StatelessWidget {
  final LanguageProvider lang;
  final AppLocalizations l;

  const _LanguageToggle({required this.lang, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangButton(
              label: 'FR',
              selected: lang.locale.languageCode == 'fr',
              onTap: () => lang.setLocale('fr')),
          _LangButton(
              label: 'AR',
              selected: lang.locale.languageCode == 'ar',
              onTap: () => lang.setLocale('ar')),
        ],
      ),
    );
  }
}

// Bouton de sélection de langue
class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ),
    );
  }
}
