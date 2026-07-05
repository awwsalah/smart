class City {
  final int id;
  final String name;

  const City({required this.id, required this.name});

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}
