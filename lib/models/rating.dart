class Rating {
  final int id;
  final int requestId;
  final int clientId;
  final int driverId;
  final int stars;
  final String? comment;
  final String? createdAt;

  const Rating({
    required this.id,
    required this.requestId,
    required this.clientId,
    required this.driverId,
    required this.stars,
    this.comment,
    this.createdAt,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'] as int,
      requestId: map['request_id'] as int,
      clientId: map['client_id'] as int,
      driverId: map['driver_id'] as int,
      stars: map['stars'] as int,
      comment: map['comment'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}
