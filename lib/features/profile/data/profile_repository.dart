import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/auth_repository.dart';
import 'lookup_item.dart';
import 'profile.dart';
import 'skill.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)   // WHERE id = userId
        .maybeSingle();     // tek satır bekle; yoksa null dön
    if (data == null) return null;
    return Profile.fromJson(data);
  }

  Future<void> updateProfile({
    required String userId,
    required String fullName,
    required String userName,
    required int universityId,
    required int departmentId,
    required int classYear,
  }) async {
    await _client
        .from('profiles')
        .update({
          'full_name': fullName,
          'username': userName,
          'university_id': universityId,
          'department_id': departmentId,
          'class_year': classYear,
        })
        .eq('id', userId)
        // RLS güncellemeyi engellerse sessizce 0 satır değişir;
        // select().single() bu durumda hata fırlatır, sorunu fark ederiz.
        .select()
        .single();
  }

  // Fotoğrafı Storage'a yükler, adresini profile yazar.
  // Dosya yolu "kullanıcıId/avatar.jpg": her kullanıcı sadece kendi klasörüne yazabilir.
  Future<void> uploadAvatar(String userId, Uint8List bytes) async {
    final path = '$userId/avatar.jpg';
    await _client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );
    // Adres hep aynı olduğu için sona zaman ekliyoruz; yoksa uygulama eski fotoğrafı önbellekten gösterir
    final url = _client.storage.from('avatars').getPublicUrl(path);
    final freshUrl = '$url?t=${DateTime.now().millisecondsSinceEpoch}';

    await _client
        .from('profiles')
        .update({'avatar_url': freshUrl})
        .eq('id', userId)
        .select()
        .single();
  }

  Future<List<Skill>> getSkills() async {
    final data = await _client.from('skills').select().order('category').order('name');
    return data.map(Skill.fromJson).toList();
  }

  Future<Set<int>> getSkillIds(String userId) async {
    final data = await _client
        .from('profile_skills')
        .select('skill_id')
        .eq('profile_id', userId);
    return data.map((row) => row['skill_id'] as int).toSet();
  }

  // Basit yol: kullanıcının eski yeteneklerini sil, seçilenleri yeniden ekle
  Future<void> saveSkills(String userId, Set<int> skillIds) async {
    await _client.from('profile_skills').delete().eq('profile_id', userId);
    if (skillIds.isEmpty) return;
    await _client.from('profile_skills').insert([
      for (final id in skillIds) {'profile_id': userId, 'skill_id': id},
    ]);
  }

  Future<List<LookupItem>> getUniversities() => _getLookup('universities');

  Future<List<LookupItem>> getDepartments() => _getLookup('departments');

  Future<List<LookupItem>> _getLookup(String table) async {
    final data = await _client.from(table).select('id, name').order('name');
    return data.map(LookupItem.fromJson).toList();
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

// Giriş yapmış kullanıcının profili.
// Giriş/çıkış olunca otomatik yeniden çekilir.
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(authStateProvider); // auth değişince bu provider da yenilensin
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return null;
  return ref.watch(profileRepositoryProvider).getProfile(user.id);
});

final universitiesProvider = FutureProvider<List<LookupItem>>((ref) {
  return ref.watch(profileRepositoryProvider).getUniversities();
});

final departmentsProvider = FutureProvider<List<LookupItem>>((ref) {
  return ref.watch(profileRepositoryProvider).getDepartments();
});

final skillsProvider = FutureProvider<List<Skill>>((ref) {
  return ref.watch(profileRepositoryProvider).getSkills();
});

// Giriş yapmış kullanıcının seçtiği yeteneklerin id'leri
final mySkillIdsProvider = FutureProvider<Set<int>>((ref) async {
  ref.watch(authStateProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return {};
  return ref.watch(profileRepositoryProvider).getSkillIds(user.id);
});
