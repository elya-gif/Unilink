class Profile {
  const Profile({
    required this.id,
    this.userName,
    this.fullName,
    this.universityId,
    this.departmentId,
    this.classYear,
    this.avatarUrl,
  });

  final String id;
  final String? userName;
  final String? fullName;
  final int? universityId;
  final int? departmentId;
  final int? classYear;
  final String? avatarUrl;

  // Onboarding'de doldurulan alanların hepsi dolu mu?
  bool get isComplete =>
      userName != null &&
      fullName != null &&
      universityId != null &&
      departmentId != null &&
      classYear != null;

  // Supabase'den gelen satırı (Map) Profile nesnesine çevirir.
  // Sol taraf Dart'taki isim, sağ taraf veritabanındaki kolon adı.
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      userName: json['username'] as String?,
      fullName: json['full_name'] as String?,
      universityId: json['university_id'] as int?,
      departmentId: json['department_id'] as int?,
      classYear: json['class_year'] as int?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
