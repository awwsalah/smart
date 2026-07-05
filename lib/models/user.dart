/// App user — role is `client` or `driver`.
class User {
  final int? id;
  final String fullName;
  final String phone;
  final String passwordHash;
  final String role;
  final int? cityId;
  final int? districtId;
  final int? streetId;
  final String? landmarkNote;
  final String? vehiclePlate;
  final String? vehicleType;
  final int? serviceCityId;
  final String? createdAt;

  const User({
    this.id,
    required this.fullName,
    required this.phone,
    required this.passwordHash,
    required this.role,
    this.cityId,
    this.districtId,
    this.streetId,
    this.landmarkNote,
    this.vehiclePlate,
    this.vehicleType,
    this.serviceCityId,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String,
      passwordHash: map['password_hash'] as String,
      role: map['role'] as String,
      cityId: map['city_id'] as int?,
      districtId: map['district_id'] as int?,
      streetId: map['street_id'] as int?,
      landmarkNote: map['landmark_note'] as String?,
      vehiclePlate: map['vehicle_plate'] as String?,
      vehicleType: map['vehicle_type'] as String?,
      serviceCityId: map['service_city_id'] as int?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    return {
      if (includeId && id != null) 'id': id,
      'full_name': fullName,
      'phone': phone,
      'password_hash': passwordHash,
      'role': role,
      'city_id': cityId,
      'district_id': districtId,
      'street_id': streetId,
      'landmark_note': landmarkNote,
      'vehicle_plate': vehiclePlate,
      'vehicle_type': vehicleType,
      'service_city_id': serviceCityId,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  bool get isClient => role == 'client';
  bool get isDriver => role == 'driver';

  User copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? passwordHash,
    String? role,
    int? cityId,
    int? districtId,
    int? streetId,
    String? landmarkNote,
    String? vehiclePlate,
    String? vehicleType,
    int? serviceCityId,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      streetId: streetId ?? this.streetId,
      landmarkNote: landmarkNote ?? this.landmarkNote,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      serviceCityId: serviceCityId ?? this.serviceCityId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
