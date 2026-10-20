import 'package:flutter_riverpod/flutter_riverpod.dart';

// Ana sayfadaki filtrelerin o anki hali
class ProjectFilter {
  const ProjectFilter({
    this.search = '',
    this.competitionId,
    this.skillId,
    this.onlyRecruiting = true,
  });

  final String search;
  final int? competitionId;
  final int? skillId;
  final bool onlyRecruiting;
}

// Notifier: durumu (state) tutan ve onu değiştiren metotları olan sınıf.
// state'e yeni değer atanınca bu provider'ı watch eden her yer güncellenir.
class ProjectFilterNotifier extends Notifier<ProjectFilter> {
  @override
  ProjectFilter build() => const ProjectFilter();

  void setSearch(String search) => state = ProjectFilter(
        search: search.trim(),
        competitionId: state.competitionId,
        skillId: state.skillId,
        onlyRecruiting: state.onlyRecruiting,
      );

  void setCompetition(int? competitionId) => state = ProjectFilter(
        search: state.search,
        competitionId: competitionId,
        skillId: state.skillId,
        onlyRecruiting: state.onlyRecruiting,
      );

  void setSkill(int? skillId) => state = ProjectFilter(
        search: state.search,
        competitionId: state.competitionId,
        skillId: skillId,
        onlyRecruiting: state.onlyRecruiting,
      );

  void toggleOnlyRecruiting() => state = ProjectFilter(
        search: state.search,
        competitionId: state.competitionId,
        skillId: state.skillId,
        onlyRecruiting: !state.onlyRecruiting,
      );
}

final projectFilterProvider =
    NotifierProvider<ProjectFilterNotifier, ProjectFilter>(ProjectFilterNotifier.new);
