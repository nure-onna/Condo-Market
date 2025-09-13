import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ihc_marketplace/models/profile.dart';
import 'package:ihc_marketplace/services/user_service.dart';
import 'package:uuid/uuid.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _supabase = Supabase.instance.client;
  final _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _currentUserId;
  File? _imageFile;
  String? _initialAvatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (_currentUserId == null) return;
    setState(() => _isLoading = true);
    final profile = await _userService.getUserProfile(_currentUserId!);
    if (profile != null) {
      _usernameController.text = profile.username;
      _initialAvatarUrl = profile.avatarUrl;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadAvatar() async {
    if (_imageFile == null) return null;

    final fileName = '${const Uuid().v4()}.jpg';
    final filePath = 'avatars/$fileName';

    try {
      await _supabase.storage
          .from('avatars')
          .upload(
            filePath,
            _imageFile!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      final url = _supabase.storage.from('avatars').getPublicUrl(filePath);
      return url;
    } catch (e) {
      debugPrint('Erro no upload do avatar: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    String? newAvatarUrl;
    if (_imageFile != null) {
      newAvatarUrl = await _uploadAvatar();
    }

    try {
      await _userService.updateUserProfile(
        userId: _currentUserId!,
        username: _usernameController.text,
        avatarUrl: newAvatarUrl ?? _initialAvatarUrl,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao salvar perfil.')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(body: Center(child: Text('Usuário não logado.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : _initialAvatarUrl != null
                            ? NetworkImage(_initialAvatarUrl!)
                            : null,
                        child: _imageFile == null && _initialAvatarUrl == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Nome de Usuário',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um nome de usuário';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Salvar Alterações'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
