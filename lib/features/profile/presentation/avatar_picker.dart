import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/data/auth_repository.dart';
import '../data/profile_repository.dart';

// Yuvarlak profil fotoğrafı; dokununca galeriden seçip yükler.
class AvatarPicker extends ConsumerStatefulWidget {
  const AvatarPicker({super.key});

  @override
  ConsumerState<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends ConsumerState<AvatarPicker> {
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    // Küçültüp sıkıştırıyoruz: hem yükleme hızlı olur hem Storage kotası dolmaz
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image == null) return; // kullanıcı vazgeçti

    setState(() => _isUploading = true);
    try {
      final bytes = await image.readAsBytes();
      await ref.read(profileRepositoryProvider).uploadAvatar(user.id, bytes);
      ref.invalidate(currentProfileProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf yüklenemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ref.watch(currentProfileProvider).value?.avatarUrl;

    return Center(
      child: GestureDetector(
        onTap: _isUploading ? null : _pickAndUpload,
        child: CircleAvatar(
          radius: 48,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: _isUploading
              ? const CircularProgressIndicator()
              : avatarUrl == null
                  ? const Icon(Icons.add_a_photo, size: 32)
                  : null,
        ),
      ),
    );
  }
}
