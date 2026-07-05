/// Pickup request with optional joined labels for list/detail screens.
class PickupRequest {
  final int id;
  final int clientId;
  final int? driverId;
  final int wasteTypeId;
  final String? size;
  final String? preferredDate;
  final String? preferredSlot;
  final String? note;
  final int? cityId;
  final int? districtId;
  final int? streetId;
  final String? landmarkNote;
  final String status;
  final String? cancelReason;
  final String? paymentMethod;
  final double fee;
  final String? createdAt;
  final String? updatedAt;

  // Joined display fields (from queries).
  final String? wasteTypeName;
  final String? cityName;
  final String? districtName;
  final String? streetName;
  final String? driverName;
  final String? driverPhone;
  final String? clientName;
  final String? clientPhone;

  const PickupRequest({
    required this.id,
    required this.clientId,
    this.driverId,
    required this.wasteTypeId,
    this.size,
    this.preferredDate,
    this.preferredSlot,
    this.note,
    this.cityId,
    this.districtId,
    this.streetId,
    this.landmarkNote,
    required this.status,
    this.cancelReason,
    this.paymentMethod,
    this.fee = 0,
    this.createdAt,
    this.updatedAt,
    this.wasteTypeName,
    this.cityName,
    this.districtName,
    this.streetName,
    this.driverName,
    this.driverPhone,
    this.clientName,
    this.clientPhone,
  });

  factory PickupRequest.fromMap(Map<String, dynamic> map) {
    return PickupRequest(
      id: map['id'] as int,
      clientId: map['client_id'] as int,
      driverId: map['driver_id'] as int?,
      wasteTypeId: map['waste_type_id'] as int,
      size: map['size'] as String?,
      preferredDate: map['preferred_date'] as String?,
      preferredSlot: map['preferred_slot'] as String?,
      note: map['note'] as String?,
      cityId: map['city_id'] as int?,
      districtId: map['district_id'] as int?,
      streetId: map['street_id'] as int?,
      landmarkNote: map['landmark_note'] as String?,
      status: map['status'] as String,
      cancelReason: map['cancel_reason'] as String?,
      paymentMethod: map['payment_method'] as String?,
      fee: (map['fee'] as num?)?.toDouble() ?? 0,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      wasteTypeName: map['waste_type_name'] as String?,
      cityName: map['city_name'] as String?,
      districtName: map['district_name'] as String?,
      streetName: map['street_name'] as String?,
      driverName: map['driver_name'] as String?,
      driverPhone: map['driver_phone'] as String?,
      clientName: map['client_name'] as String?,
      clientPhone: map['client_phone'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'client_id': clientId,
      'driver_id': driverId,
      'waste_type_id': wasteTypeId,
      'size': size,
      'preferred_date': preferredDate,
      'preferred_slot': preferredSlot,
      'note': note,
      'city_id': cityId,
      'district_id': districtId,
      'street_id': streetId,
      'landmark_note': landmarkNote,
      'status': status,
      'payment_method': paymentMethod,
      'fee': fee,
    };
  }

  bool get hasDriver => driverId != null;

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isEnRoute => status == 'en_route';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  /// Human-readable status for the UI.
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending / Sugitaan';
      case 'accepted':
        return 'Accepted / La aqbalay';
      case 'en_route':
        return 'En Route / Wadada';
      case 'completed':
        return 'Completed / Dhammaystiran';
      case 'cancelled':
        return 'Cancelled / La joojiyay';
      default:
        return status;
    }
  }

  String get addressSummary {
    final parts = <String>[
      if (cityName != null) cityName!,
      if (districtName != null) districtName!,
      if (streetName != null) streetName!,
    ];
    if (parts.isEmpty) return landmarkNote ?? 'No address';
    var text = parts.join(', ');
    if (landmarkNote != null && landmarkNote!.isNotEmpty) {
      text = '$text ($landmarkNote)';
    }
    return text;
  }
}
