import '../models/user.dart';
import 'database_helper.dart';

/// CRUD helpers for the users table.
class UserDao {
  Future<User?> getUserByPhone(String phone) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<bool> phoneExists(String phone) async {
    final user = await getUserByPhone(phone);
    return user != null;
  }

  Future<int> insertUser(User user) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('users', user.toMap(includeId: false));
  }
}
