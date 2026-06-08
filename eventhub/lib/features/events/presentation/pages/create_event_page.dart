import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';

class CreateEventPage extends StatefulWidget {
  final Event? event;
  const CreateEventPage({super.key, this.event});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  EventCategory _selectedCategory = EventCategory.conference;
  bool _isFree = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _isEditing = true;
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.location;
      _cityController.text = widget.event!.city ?? '';
      _priceController.text = widget.event!.price.toString();
      _maxParticipantsController.text = widget.event!.maxParticipants.toString();
      _selectedDate = widget.event!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.date);
      _selectedCategory = widget.event!.category;
      _isFree = widget.event!.isFree;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.selectImageSource),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.camera),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.gallery),
            ),
          ),
        ],
      ),
    );
    if (source != null) {
      final picked = await _imagePicker.pickImage(source: source);
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    }
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      final event = Event(
        id: widget.event?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: dateTime,
        location: _locationController.text.trim(),
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        price: _isFree ? 0 : double.parse(_priceController.text),
        maxParticipants: int.parse(_maxParticipantsController.text),
        category: _selectedCategory,
        organizerId: Supabase.instance.client.auth.currentUser?.id ?? '',
      );
      if (_isEditing) {
        context.read<EventBloc>().add(UpdateEventEvent(event: event));
      } else {
        context.read<EventBloc>().add(CreateEventEvent(event: event));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editEvent : l10n.createEvent),
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventCreated || state is EventUpdated) {
            Navigator.pop(context, true);
          }
          if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : widget.event?.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.event!.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_photo_alternate,
                                        size: 48),
                                    const SizedBox(height: 8),
                                    Text(l10n.addEventImage),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.eventTitle,
                    prefixIcon: const Icon(Icons.event),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    prefixIcon: const Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<EventCategory>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: EventCategory.values
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: l10n.date,
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (time != null) {
                            setState(() => _selectedTime = time);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: l10n.time,
                            prefixIcon: const Icon(Icons.access_time),
                          ),
                          child: Text(_selectedTime.format(context)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: l10n.location,
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Location is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: l10n.city,
                    prefixIcon: const Icon(Icons.map),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxParticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.maxParticipants,
                    prefixIcon: const Icon(Icons.people),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(l10n.freeEvent),
                  value: _isFree,
                  onChanged: (value) =>
                      setState(() => _isFree = value),
                ),
                if (!_isFree) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.price,
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    validator: (v) =>
                        _isFree || (v != null && v.isNotEmpty)
                            ? null
                            : 'Required',
                  ),
                ],
                const SizedBox(height: 32),
                BlocBuilder<EventBloc, EventState>(
                  builder: (context, state) {
                    if (state is EventLoading) {
                      return const LoadingWidget();
                    }
                    return ElevatedButton(
                      onPressed: _onSubmit,
                      child: Text(_isEditing ? l10n.updateEvent : l10n.createEvent),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
