/*
 * FICHIER : event_form_screen.dart
 * RÔLE : Permet de créer un nouvel événement ou modifier un événement existant
 * DESCRIPTION (POUR DÉBUTANTS) : Cet écran affiche un formulaire avec :
 * titre, description, date/heure, lieu, et catégorie.
 * Si on passe un événement en paramètre, on est en mode "modification" (les champs sont pré-remplis).
 * Sinon, on est en mode "création".
 * UTILISÉ PAR : EventsListScreen (bouton +) ou EventDetailScreen (bouton modifier)
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventhub_app/l10n/app_localizations.dart';
import '../../models/category.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event; // null = création, non-null = modification
  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  // Clé du formulaire pour valider les champs
  final _formKey = GlobalKey<FormState>();
  // Contrôleurs pour récupérer le texte saisi
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  // Date et heure sélectionnées
  DateTime? _selectedDate;
  // Catégorie sélectionnée
  Category? _selectedCategory;

  // Indique si on est en mode modification (event non null)
  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    // Pré-remplit les champs si on modifie un événement existant
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _selectedDate = e?.date;

    // Une fois l'écran affiché, on charge les catégories
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<EventProvider>().loadCategories();
      // Si on modifie, on sélectionne la catégorie actuelle
      if (e?.categoryName != null && mounted) {
        final categories = context.read<EventProvider>().categories;
        setState(() {
          _selectedCategory = categories
              .where((c) => c.name == e!.categoryName)
              .firstOrNull;
        });
      }
    });
  }

  @override
  void dispose() {
    // Nettoie les contrôleurs pour éviter les fuites mémoire
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  // Méthode pour choisir une date et une heure
  Future<void> _pickDate() async {
    final now = DateTime.now();
    // Affiche le sélecteur de date
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)), // Peut choisir hier ou après
      lastDate: now.add(const Duration(days: 365 * 5)), // Jusqu'à 5 ans
    );
    if (picked == null || !mounted) return;

    // Après la date, affiche le sélecteur d'heure
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? now),
    );
    if (!mounted) return;

    // Combine la date et l'heure
    setState(() {
      _selectedDate = DateTime(
        picked.year, picked.month, picked.day,
        time?.hour ?? 0, time?.minute ?? 0,
      );
    });
  }

  // Méthode pour soumettre le formulaire (créer ou modifier)
  Future<void> _submit() async {
    // Vérifie que le formulaire est valide
    if (!_formKey.currentState!.validate()) return;

    // Vérifie qu'une date a été choisie
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectDate),
            backgroundColor: Colors.orange),
      );
      return;
    }

    // Construit la requête avec les données du formulaire
    final request = EventRequest(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      date: _selectedDate!,
      location: _locationCtrl.text.trim(),
      categoryId: _selectedCategory?.id,
    );

    final ep = context.read<EventProvider>();
    bool ok;
    if (_isEditing) {
      // Mode modification
      ok = await ep.updateEvent(widget.event!.id, request);
    } else {
      // Mode création
      ok = await ep.createEvent(request);
    }

    if (!mounted) return;
    if (ok) {
      // Succès : retour à l'écran précédent
      Navigator.pop(context);
    } else {
      // Échec : affiche l'erreur
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ep.error ?? 'Erreur'),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final ep = context.watch<EventProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.editEvent : l.addEvent,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre de section : Titre
              _SectionHeader(label: l.eventTitle),
              _FormField(
                controller: _titleCtrl,
                label: l.eventTitle,
                icon: Icons.title,
                validator: (v) => (v == null || v.isEmpty) ? l.fieldRequired : null,
              ),
              const SizedBox(height: 16),

              // Titre de section : Description
              _SectionHeader(label: l.description),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4, // 4 lignes pour la description
                decoration: InputDecoration(
                  labelText: l.description,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true, fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),

              // Titre de section : Date
              _SectionHeader(label: l.date),
              InkWell(
                onTap: _pickDate, // Ouvre le sélecteur de date
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  ${_selectedDate!.hour.toString().padLeft(2, '0')}:${_selectedDate!.minute.toString().padLeft(2, '0')}'
                            : l.selectDate,
                        style: TextStyle(
                          color: _selectedDate != null ? Colors.black87 : Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Titre de section : Lieu
              _SectionHeader(label: l.location),
              _FormField(
                controller: _locationCtrl,
                label: l.location,
                icon: Icons.location_on_outlined,
                validator: (v) => (v == null || v.isEmpty) ? l.fieldRequired : null,
              ),
              const SizedBox(height: 16),

              // Titre de section : Catégorie
              _SectionHeader(label: l.category),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: l.selectCategory,
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true, fillColor: Colors.grey.shade50,
                ),
                items: ep.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (c) => setState(() => _selectedCategory = c),
              ),
              const SizedBox(height: 32),

              // Bouton Sauvegarder
              ElevatedButton(
                onPressed: ep.loading ? null : _submit, // Désactivé si chargement
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: ep.loading
                    ? const SizedBox(height: 22, width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l.save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget pour afficher un titre de section
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: TextStyle(color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold, fontSize: 13)),
      );
}

// Widget réutilisable pour un champ de saisie standard
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;

  const _FormField({required this.controller, required this.label, required this.icon, this.validator});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller, validator: validator,
        decoration: InputDecoration(
          labelText: label, prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true, fillColor: Colors.grey.shade50,
        ),
      );
}
