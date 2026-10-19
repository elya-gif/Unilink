import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/auth_repository.dart';
import 'lookup_item.dart';
import 'profile.dart';

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
