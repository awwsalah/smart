import '../models/waste_type.dart';
import 'database_helper.dart';

class WasteTypeDao {
  Future<List<WasteType>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('waste_types', orderBy: 'name ASC');
    return rows.map(WasteType.fromMap).toList();
  }

  Future<WasteType?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'waste_types',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WasteType.fromMap(rows.first);
  }
}
