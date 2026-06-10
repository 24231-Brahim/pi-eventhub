import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventhub/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/l10n/app_localizations.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const GetProfileEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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

  Future<String?> _uploadPhoto() async {
    if (_selectedImage == null) return _photoUrl;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final fileName = 'avatars/$userId.jpg';
      await Supabase.instance.client.storage
          .from('avatars')
          .upload(fileName, _selectedImage!,
              fileOptions: const FileOptions(contentType: 'image/jpeg'));
      return Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }

  Future<void> _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final photoUrl = await _uploadPhoto();
      if (!mounted) return;
      context.read<ProfileBloc>().add(
            UpdateProfileEvent(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              photoUrl: photoUrl,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _nameController.text = state.profile.name;
            _phoneController.text = state.profile.phone ?? '';
            _photoUrl = state.profile.photoUrl;
          }
          if (state is ProfileUpdated) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.profileUpdated)),
            );
          }
          if (state is ProfileError) {
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
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_photoUrl != null
                              ? NetworkImage(_photoUrl!)
                              : null),
                      child: _selectedImage == null && _photoUrl == null
                          ? Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? l10n.nameRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phone,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileLoading) {
                      return const LoadingWidget();
                    }
                    return ElevatedButton(
                      onPressed: _onSave,
                      child: Text(l10n.saveChanges),
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
