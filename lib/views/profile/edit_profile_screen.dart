import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController _usernameController = TextEditingController();

  File? _profileImage;
  String? _photoUrl;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProfile);
  }

  // ================= LOAD PROFILE =================
  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('profiles')
          .select('username, photo_url')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        _usernameController.text = data['username'] ?? '';
        _photoUrl = data['photo_url'];
      }
    } catch (e) {
      debugPrint('❌ Load profile error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  // ================= UPLOAD PHOTO =================
  Future<String?> _uploadPhoto(File file) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final ext = file.path.split('.').last;
    final filePath = '${user.id}.$ext';

    await supabase.storage
        .from('avatars')
        .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

    return supabase.storage.from('avatars').getPublicUrl(filePath);
  }

  // ================= SAVE PROFILE =================
  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (_usernameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Username tidak boleh kosong');
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? photoUrl = _photoUrl;

      if (_profileImage != null) {
        photoUrl = await _uploadPhoto(_profileImage!);
      }

      await supabase.from('profiles').upsert({
        'id': user.id,
        'username': _usernameController.text.trim(),
        'photo_url': photoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 🔥 AUTO REFRESH PROFILE
      Get.back(result: true);
    } catch (e) {
      debugPrint('❌ Save profile error: $e');
      Get.snackbar('Error', 'Gagal menyimpan profil');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _ProfileAvatar(
              image: _profileImage,
              photoUrl: _photoUrl,
              username: _usernameController.text,
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _pickImage, child: const Text('Ganti Foto')),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= AVATAR WIDGET =================
class _ProfileAvatar extends StatelessWidget {
  final File? image;
  final String? photoUrl;
  final String username;

  const _ProfileAvatar({
    required this.image,
    required this.photoUrl,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return CircleAvatar(radius: 48, backgroundImage: FileImage(image!));
    }

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(radius: 48, backgroundImage: NetworkImage(photoUrl!));
    }

    return CircleAvatar(
      radius: 48,
      backgroundColor: Colors.brown.shade700,
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
