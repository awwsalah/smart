import 'package:sqflite/sqflite.dart';

import '../models/driver_dashboard_counts.dart';
import '../models/pickup_request.dart';
import 'database_helper.dart';

/// Reads and writes pickup requests.
class RequestDao {
  static const _detailQuery = '''
    SELECT
      r.*,
      wt.name AS waste_type_name,
      c.name AS city_name,
      d.name AS district_name,
      s.name AS street_name,
      dr.full_name AS driver_name,
      dr.phone AS driver_phone,
      cl.full_name AS client_name,
      cl.phone AS client_phone
    FROM requests r
    INNER JOIN waste_types wt ON r.waste_type_id = wt.id
    LEFT JOIN cities c ON r.city_id = c.id
    LEFT JOIN districts d ON r.district_id = d.id
    LEFT JOIN streets s ON r.street_id = s.id
    LEFT JOIN users dr ON r.driver_id = dr.id
    LEFT JOIN users cl ON r.client_id = cl.id
  ''';

  Future<int> insert(PickupRequest request) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('requests', request.toInsertMap());
  }

  Future<List<PickupRequest>> getByClientId(int clientId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(
      '''
      $_detailQuery
      WHERE r.client_id = ?
      ORDER BY r.created_at DESC
      ''',
      [clientId],
    );
    return rows.map(PickupRequest.fromMap).toList();
  }

  Future<List<PickupRequest>> getPendingByServiceCity(int serviceCityId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(
      '''
      $_detailQuery
      WHERE r.status = 'pending' AND r.city_id = ?
      ORDER BY r.created_at ASC
      ''',
      [serviceCityId],
    );
    return rows.map(PickupRequest.fromMap).toList();
  }

  /// Active jobs assigned to this driver (accepted or en_route).
  Future<List<PickupRequest>> getActiveByDriver(int driverId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(
      '''
      $_detailQuery
      WHERE r.driver_id = ? AND r.status IN ('accepted', 'en_route')
      ORDER BY r.updated_at DESC, r.created_at DESC
      ''',
      [driverId],
    );
    return rows.map(PickupRequest.fromMap).toList();
  }

  Future<DriverDashboardCounts> getDriverDashboardCounts({
    required int driverId,
    required int serviceCityId,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final pending = Sqflite.firstIntValue(await db.rawQuery(
      '''
      SELECT COUNT(*) FROM requests
      WHERE status = 'pending' AND city_id = ?
      ''',
      [serviceCityId],
    ));

    final accepted = Sqflite.firstIntValue(await db.rawQuery(
      '''
      SELECT COUNT(*) FROM requests
      WHERE driver_id = ? AND status IN ('accepted', 'en_route')
      ''',
      [driverId],
    ));

    final completedToday = Sqflite.firstIntValue(await db.rawQuery(
      '''
      SELECT COUNT(*) FROM requests
      WHERE driver_id = ? AND status = 'completed'
        AND date(updated_at) = date('now')
      ''',
      [driverId],
    ));

    return DriverDashboardCounts(
      pending: pending ?? 0,
      accepted: accepted ?? 0,
      completedToday: completedToday ?? 0,
    );
  }

  Future<PickupRequest?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(
      '''
      $_detailQuery
      WHERE r.id = ?
      LIMIT 1
      ''',
      [id],
    );
    if (rows.isEmpty) return null;
    return PickupRequest.fromMap(rows.first);
  }

  /// Driver accepts a pending request in their service city.
  Future<int> acceptRequest({
    required int requestId,
    required int driverId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'requests',
      {
        'status': 'accepted',
        'driver_id': driverId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: "id = ? AND status = 'pending'",
      whereArgs: [requestId],
    );
  }

  /// Driver moves accepted → en_route → completed.
  Future<int> updateStatus({
    required int requestId,
    required int driverId,
    required String newStatus,
    required String expectedCurrentStatus,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'requests',
      {
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND driver_id = ? AND status = ?',
      whereArgs: [requestId, driverId, expectedCurrentStatus],
    );
  }
}
