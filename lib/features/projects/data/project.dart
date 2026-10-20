class ProjectRole {
  const ProjectRole({
    required this.id,
    required this.title,
    required this.slots,
    this.description,
    this.skillNames = const [],
    this.skillIds = const [],
  });

  final int id;
  final String title;
  final int slots; // bu rolde kaç kişi aranıyor
  final String? description;
  final List<String> skillNames; // rolün istediği yetenekler
  final List<int> skillIds;

  factory ProjectRole.fromJson(Map<String, dynamic> json) {
    final skills = json['skills'] as List<dynamic>? ?? [];
    return ProjectRole(
      id: json['id'] as int,
      title: json['title'] as String,
      slots: json['slots'] as int,
      description: json['description'] as String?,
      skillNames: [for (final skill in skills) skill['name'] as String],
      skillIds: [for (final skill in skills) if (skill['id'] != null) skill['id'] as int],
    );
  }
}

// Proje sahibinin kartta gösterilecek bilgileri
class ProjectOwner {
  const ProjectOwner({
    this.fullName,
    this.userName,
    this.avatarUrl,
    this.universityName,
    this.departmentName,
  });

  final String? fullName;
  final String? userName;
  final String? avatarUrl;
  final String? universityName;
  final String? departmentName;

  factory ProjectOwner.fromJson(Map<String, dynamic> json) {
    return ProjectOwner(
      fullName: json['full_name'] as String?,
      userName: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      universityName: (json['universities'] as Map<String, dynamic>?)?['name'] as String?,
      departmentName: (json['departments'] as Map<String, dynamic>?)?['name'] as String?,
    );
  }
}

class Project {
  const Project({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.status,
    required this.openToOtherUniversities,
    required this.createdAt,
    this.competitionName,
    this.roles = const [],
  });

  final int id;
  final String ownerId;
  final String title;
  final String description;
  final String status;
  final bool openToOtherUniversities;
  final DateTime createdAt;
  final String? competitionName;
  final List<ProjectRole> roles;

  bool get isRecruiting => status == 'recruiting';

  // Sorguda ilişkili tabloları da istediğimiz için (competitions, project_roles)
  // json içinde iç içe Map ve liste olarak geliyorlar.
  factory Project.fromJson(Map<String, dynamic> json) {
    final competition = json['competitions'] as Map<String, dynamic>?;
    final roles = json['project_roles'] as List<dynamic>? ?? [];

    return Project(
      id: json['id'] as int,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      openToOtherUniversities: json['open_to_other_universities'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      competitionName: competition?['name'] as String?,
      roles: roles
          .map((role) => ProjectRole.fromJson(role as Map<String, dynamic>))
          .toList(),
    );
  }
}
