import '../models/city.dart';
import '../models/district.dart';
import '../models/street.dart';
import 'database_helper.dart';

/// Reads cities, districts, and streets for address dropdowns.
class LocationDao {
  Future<List<City>> getCities() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('cities', orderBy: 'name ASC');
    return rows.map(City.fromMap).toList();
  }

  Future<List<District>> getDistrictsByCity(int cityId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'districts',
      where: 'city_id = ?',
      whereArgs: [cityId],
      orderBy: 'name ASC',
    );
    return rows.map(District.fromMap).toList();
  }

  Future<List<Street>> getStreetsByDistrict(int districtId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'streets',
      where: 'district_id = ?',
      whereArgs: [districtId],
      orderBy: 'name ASC',
    );
    return rows.map(Street.fromMap).toList();
  }
}
