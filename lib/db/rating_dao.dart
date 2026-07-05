import '../models/rating.dart';
import 'database_helper.dart';

class RatingDao {
  Future<int> insert({
    required int requestId,
    required int clientId,
    required int driverId,
    required int stars,
    String? comment,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('ratings', {
      'request_id': requestId,
      'client_id': clientId,
      'driver_id': driverId,
      'stars': stars,
      'comment': comment,
    });
  }

  Future<Rating?> getByRequestId(int requestId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'ratings',
      where: 'request_id = ?',
      whereArgs: [requestId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Rating.fromMap(rows.first);
  }

  Future<bool> existsForRequest(int requestId) async {
    final rating = await getByRequestId(requestId);
    return rating != null;
  }
}
