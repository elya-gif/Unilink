import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../profile/data/lookup_item.dart';
import 'project.dart';
import 'project_filter.dart';

// Formdan gelen, henüz kaydedilmemiş rol bilgisi
class NewRole {
  const NewRole({required this.title, required this.slots, required this.skillIds});

  final String title;
  final int slots;
  final Set<int> skillIds;
}

class ProjectRepository {
  ProjectRepository(this._client);

  final SupabaseClient _client;

  Future<List<LookupItem>> getCompetitions() async {
    final data = await _client.from('competitions').select('id, name').order('name');
    return data.map(LookupItem.fromJson).toList();
  }

  // Sırayla: proje → roller → rollerin yetenekleri. Yeni projenin id'sini döner.
  Future<int> createProject({
    required String ownerId,
    required String title,
    required String description,
    required int? competitionId,
    required bool openToOtherUniversities,
    required List<NewRole> roles,
  }) async {
    final project = await _client
        .from('projects')
        .insert({
          'owner_id': ownerId,
          'title': title,
          'description': description,
          'competition_id': competitionId,
          'open_to_other_universities': openToOtherUniversities,
        })
        .select('id') // eklenen satırın id'sini geri al
        .single();
    final projectId = project['id'] as int;

    for (final role in roles) {
      final savedRole = await _client
          .from('project_roles')
          .insert({'project_id': projectId, 'title': role.title, 'slots': role.slots})
          .select('id')
          .single();

      if (role.skillIds.isNotEmpty) {
        await _client.from('project_role_skills').insert([
          for (final skillId in role.skillIds)
            {'role_id': savedRole['id'], 'skill_id': skillId},
        ]);
      }
    }
    return projectId;
  }

  Future<List<Project>> getProjects(ProjectFilter filter) async {
    var query = _client
        .from('projects')
        // * = projenin tüm kolonları; yanındakiler foreign key üzerinden
        // bağlı tablolardan gelen veriler (SQL'deki JOIN gibi)
        .select('*, competitions(name), project_roles(id, title, slots, skills(id, name))');

    // Her filtre sorguya bir WHERE koşulu ekler
    if (filter.onlyRecruiting) query = query.eq('status', 'recruiting');
    if (filter.competitionId != null) {
      query = query.eq('competition_id', filter.competitionId!);
    }
    if (filter.search.isNotEmpty) {
      // , ( ) % karakterleri or() sözdizimini bozar, temizliyoruz
      final text = filter.search.replaceAll(RegExp(r'[,()%]'), '');
      query = query.or('title.ilike.%$text%,description.ilike.%$text%');
    }

    final data = await query.order('created_at', ascending: false); // en yeni en üstte
    final projects = data.map(Project.fromJson).toList();

    // Yetenek filtresini telefonda yapıyoruz: rollerden biri o yeteneği istiyorsa göster.
    // (Proje sayısı artınca sunucuya taşınabilir.)
    if (filter.skillId == null) return projects;
    return projects
        .where((p) => p.roles.any((role) => role.skillIds.contains(filter.skillId)))
        .toList();
  }

  Future<Project> getProject(int id) async {
    final data = await _client
        .from('projects')
        // project_role_skills ara tablosu üzerinden rolün yeteneklerini de al
        .select('*, competitions(name), '
            'project_roles(id, title, description, slots, skills(name))')
        .eq('id', id)
        .single();
    return Project.fromJson(data);
  }

  Future<ProjectOwner?> getOwner(String userId) async {
    final data = await _client
        .from('profiles')
        .select('full_name, username, avatar_url, universities(name), departments(name)')
        .eq('id', userId)
        .maybeSingle();
    return data == null ? null : ProjectOwner.fromJson(data);
  }
}

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(Supabase.instance.client);
});

// Filtre değişince liste otomatik yeniden çekilir
final projectsProvider = FutureProvider<List<Project>>((ref) {
  final filter = ref.watch(projectFilterProvider);
  return ref.watch(projectRepositoryProvider).getProjects(filter);
});

// .family: aynı provider'ı parametreyle kullanmak için (her proje id'si için ayrı sonuç)
final projectProvider = FutureProvider.family<Project, int>((ref, id) {
  return ref.watch(projectRepositoryProvider).getProject(id);
});

final projectOwnerProvider = FutureProvider.family<ProjectOwner?, String>((ref, userId) {
  return ref.watch(projectRepositoryProvider).getOwner(userId);
});

final competitionsProvider = FutureProvider<List<LookupItem>>((ref) {
  return ref.watch(projectRepositoryProvider).getCompetitions();
});
