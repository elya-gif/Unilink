// Üniversite, bölüm gibi sadece id + isimden oluşan liste öğeleri.
class LookupItem {
  const LookupItem({required this.id, required this.name});

  final int id;
  final String name;

  factory LookupItem.fromJson(Map<String, dynamic> json) {
    return LookupItem(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
