class WasteType {
  final int id;
  final String name;
  final double estFee;

  const WasteType({
    required this.id,
    required this.name,
    required this.estFee,
  });

  factory WasteType.fromMap(Map<String, dynamic> map) {
    return WasteType(
      id: map['id'] as int,
      name: map['name'] as String,
      estFee: (map['est_fee'] as num).toDouble(),
    );
  }
}
