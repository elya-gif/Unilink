import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'project.dart';

class ProjectRepository {
  ProjectRepository(this._client);

  final SupabaseClient _client;

  Future<List<Project>> getProjects() async {
    final data = await _client
        .from('projects')
        // * = projenin tüm kolonları; yanındakiler foreign key üzerinden
        // bağlı tablolardan gelen veriler (SQL'deki JOIN gibi)
        .select('*, competitions(name), project_roles(id, title, slots)')
        .order('created_at', ascending: false); // en yeni en üstte
    return data.map(Project.fromJson).toList();
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

final projectsProvider = FutureProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).getProjects();
});

// .family: aynı provider'ı parametreyle kullanmak için (her proje id'si için ayrı sonuç)
final projectProvider = FutureProvider.family<Project, int>((ref, id) {
  return ref.watch(projectRepositoryProvider).getProject(id);
});

final projectOwnerProvider = FutureProvider.family<ProjectOwner?, String>((ref, userId) {
  return ref.watch(projectRepositoryProvider).getOwner(userId);
});
