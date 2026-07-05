class Street {
  final int id;
  final int districtId;
  final String name;

  const Street({
    required this.id,
    required this.districtId,
    required this.name,
  });

  factory Street.fromMap(Map<String, dynamic> map) {
    return Street(
      id: map['id'] as int,
      districtId: map['district_id'] as int,
      name: map['name'] as String,
    );
  }
}
