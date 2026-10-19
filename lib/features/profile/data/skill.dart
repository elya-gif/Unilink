class Skill {
  const Skill({required this.id, required this.name, required this.category});

  final int id;
  final String name;
  final String category;

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
    );
  }
}
