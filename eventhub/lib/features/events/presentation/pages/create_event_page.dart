import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventhub/core/di/injection_container.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/services/file_import_service.dart';
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
  final _fileImportService = FileImportService();

  final _invitationEmailController = TextEditingController();
  final _invitationNameController = TextEditingController();

  File? _selectedImage;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;
  EventCategory _selectedCategory = EventCategory.conference;
  bool _isFree = false;
  bool _isEditing = false;
  bool _isPrivate = false;
  bool _isSavingInvitations = false;
  bool _isLoadingInvitations = false;
  final List<Map<String, String>> _invitations = [];

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
      if (widget.event!.endDate != null) {
        _selectedEndDate = widget.event!.endDate;
        _selectedEndTime = TimeOfDay.fromDateTime(widget.event!.endDate!);
      }
      _selectedCategory = widget.event!.category;
      _isFree = widget.event!.isFree;
      _isPrivate = widget.event!.isPrivate;
      _loadExistingInvitations();
    }
  }

  Future<void> _loadExistingInvitations() async {
    setState(() => _isLoadingInvitations = true);
    final repository = sl<EventRepository>();
    final result = await repository.getInvitations(widget.event!.id);
    if (!mounted) return;
    result.fold(
      (failure) => null,
      (invitations) => setState(() {
        _invitations.addAll(invitations.map((inv) => {
              'id': inv.id,
              'email': inv.email,
              'name': inv.name,
            }));
      }),
    );
    setState(() => _isLoadingInvitations = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _maxParticipantsController.dispose();
    _invitationEmailController.dispose();
    _invitationNameController.dispose();
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

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return widget.event?.imageUrl;
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage
          .from('event-images')
          .upload(fileName, _selectedImage!,
              fileOptions: const FileOptions(contentType: 'image/jpeg'));
      return Supabase.instance.client.storage
          .from('event-images')
          .getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }

  Future<void> _addInvitation() {
    final email = _invitationEmailController.text.trim();
    final name = _invitationNameController.text.trim();
    if (email.isEmpty) return Future.value();
    setState(() {
      _invitations.add({'email': email, 'name': name});
      _invitationEmailController.clear();
      _invitationNameController.clear();
    });
    return Future.value();
  }

  Future<void> _removeInvitation(int index) async {
    final id = _invitations[index]['id'];
    if (id != null && id.isNotEmpty) {
      final repository = sl<EventRepository>();
      final result = await repository.deleteInvitation(id);
      if (!mounted) return;
      final failure = result.fold((f) => f, (_) => null);
      if (failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    setState(() => _invitations.removeAt(index));
  }

  Future<void> _importFromFile() async {
    final l10n = AppLocalizations.of(context)!;
    final file = await _fileImportService.pickFile();
    if (file == null) return;

    final result = await _fileImportService.importInvitations(file);
    if (!mounted) return;

    setState(() {
      _invitations.addAll(result.entries);
    });

    if (result.errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.importErrors(result.errors.length)),
          backgroundColor: Colors.orange,
        ),
      );
    }
    if (result.validRows > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.importSuccess(result.validRows)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _saveInvitations(String eventId) async {
    final newInvitations =
        _invitations.where((inv) => (inv['id'] ?? '').isEmpty).toList();
    if (newInvitations.isEmpty) {
      if (mounted) Navigator.pop(context, true);
      return;
    }
    setState(() => _isSavingInvitations = true);
    try {
      final repository = sl<EventRepository>();
      final result =
          await repository.createInvitationsBulk(eventId, newInvitations);
      if (!mounted) return;
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invitationsImported),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSavingInvitations = false);
    }
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final imageUrl = await _uploadImage();
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      DateTime? endDateTime;
      if (_selectedEndDate != null) {
        endDateTime = DateTime(
          _selectedEndDate!.year,
          _selectedEndDate!.month,
          _selectedEndDate!.day,
          _selectedEndTime?.hour ?? 23,
          _selectedEndTime?.minute ?? 59,
        );
      }
      final event = Event(
        id: widget.event?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        date: dateTime,
        endDate: endDateTime,
        location: _locationController.text.trim(),
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        price: _isFree ? 0 : double.parse(_priceController.text),
        maxParticipants: int.parse(_maxParticipantsController.text),
        category: _selectedCategory,
        status: _isEditing ? widget.event!.status : EventStatus.published,
        organizerId: Supabase.instance.client.auth.currentUser?.id ?? '',
        isPrivate: _isPrivate,
      );
      if (!mounted) return;
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
          if (state is EventCreated) {
            _saveInvitations(state.event.id);
          } else if (state is EventUpdated) {
            _saveInvitations(state.event.id);
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
                      v == null || v.isEmpty ? l10n.titleRequired : null,
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
                      v == null || v.isEmpty ? l10n.descriptionRequired : null,
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
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedEndDate ?? _selectedDate.add(const Duration(days: 1)),
                      firstDate: _selectedDate,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _selectedEndDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '${l10n.date} (optional)',
                      prefixIcon: const Icon(Icons.event),
                    ),
                    child: Text(
                      _selectedEndDate != null
                          ? '${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}'
                          : '-',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: l10n.location,
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? l10n.locationRequired : null,
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
                      v == null || v.isEmpty ? l10n.required : null,
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
                            : l10n.required,
                  ),
                ],
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  l10n.eventVisibility,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(l10n.privateEvent),
                  subtitle: Text(l10n.onlyInvitedCanBook),
                  value: _isPrivate,
                  onChanged: (value) =>
                      setState(() => _isPrivate = value),
                  secondary: Icon(
                    _isPrivate ? Icons.lock : Icons.public,
                    color: _isPrivate ? Colors.red : Colors.green,
                  ),
                ),
                if (_isPrivate) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.invitedPeople,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingInvitations)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: LoadingWidget()),
                    )
                  else if (_invitations.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          l10n.noInvitations,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _invitations.length,
                      itemBuilder: (context, index) {
                        final inv = _invitations[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.person_outline),
                          title: Text(inv['email'] ?? ''),
                          subtitle: (inv['name'] ?? '').isNotEmpty
                              ? Text(inv['name']!)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _removeInvitation(index),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _invitationEmailController,
                          decoration: InputDecoration(
                            labelText: l10n.emailHint,
                            prefixIcon: const Icon(Icons.email),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _invitationNameController,
                          decoration: InputDecoration(
                            labelText: l10n.nameHint,
                            prefixIcon: const Icon(Icons.person),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _addInvitation,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _importFromFile,
                    icon: const Icon(Icons.upload_file),
                    label: Text(l10n.importFromFile),
                  ),
                ],
                const SizedBox(height: 32),
                BlocBuilder<EventBloc, EventState>(
                  builder: (context, state) {
                    if (state is EventLoading || _isSavingInvitations) {
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
