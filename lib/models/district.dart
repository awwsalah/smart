class District {
  final int id;
  final int cityId;
  final String name;

  const District({
    required this.id,
    required this.cityId,
    required this.name,
  });

  factory District.fromMap(Map<String, dynamic> map) {
    return District(
      id: map['id'] as int,
      cityId: map['city_id'] as int,
      name: map['name'] as String,
    );
  }
}
