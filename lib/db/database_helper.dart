import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../services/password_service.dart';

/// Opens SQLite, creates tables, and seeds reference data on first launch.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'waste_management.db';
  static const int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        // Enforce foreign keys (location + request relations).
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedFromJson(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name       TEXT NOT NULL,
        phone           TEXT NOT NULL UNIQUE,
        password_hash   TEXT NOT NULL,
        role            TEXT NOT NULL CHECK (role IN ('client','driver')),
        city_id         INTEGER,
        district_id     INTEGER,
        street_id       INTEGER,
        landmark_note   TEXT,
        vehicle_plate   TEXT,
        vehicle_type    TEXT,
        service_city_id INTEGER,
        created_at      TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE cities (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE districts (
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        city_id INTEGER NOT NULL,
        name    TEXT NOT NULL,
        FOREIGN KEY (city_id) REFERENCES cities(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE streets (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        district_id INTEGER NOT NULL,
        name        TEXT NOT NULL,
        FOREIGN KEY (district_id) REFERENCES districts(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE waste_types (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT NOT NULL,
        est_fee  REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE requests (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id      INTEGER NOT NULL,
        driver_id      INTEGER,
        waste_type_id  INTEGER NOT NULL,
        size           TEXT,
        preferred_date TEXT,
        preferred_slot TEXT,
        note           TEXT,
        city_id        INTEGER,
        district_id    INTEGER,
        street_id      INTEGER,
        landmark_note  TEXT,
        status         TEXT NOT NULL DEFAULT 'pending'
                       CHECK (status IN ('pending','accepted','en_route','completed','cancelled')),
        cancel_reason  TEXT,
        payment_method TEXT,
        fee            REAL DEFAULT 0,
        created_at     TEXT DEFAULT (datetime('now')),
        updated_at     TEXT,
        FOREIGN KEY (client_id) REFERENCES users(id),
        FOREIGN KEY (driver_id) REFERENCES users(id),
        FOREIGN KEY (waste_type_id) REFERENCES waste_types(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ratings (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        request_id INTEGER NOT NULL,
        client_id  INTEGER NOT NULL,
        driver_id  INTEGER NOT NULL,
        stars      INTEGER CHECK (stars BETWEEN 1 AND 5),
        comment    TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (request_id) REFERENCES requests(id)
      )
    ''');
  }

  /// Loads seed_data.json and inserts cities, districts, streets, waste types, demo users.
  Future<void> _seedFromJson(Database db) async {
    final jsonString = await rootBundle.loadString('seed_data.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;

    final batch = db.batch();

    for (final city in data['cities'] as List<dynamic>) {
      batch.insert('cities', {
        'id': city['id'],
        'name': city['name'],
      });
    }

    for (final district in data['districts'] as List<dynamic>) {
      batch.insert('districts', {
        'id': district['id'],
        'city_id': district['city_id'],
        'name': district['name'],
      });
    }

    for (final street in data['streets'] as List<dynamic>) {
      batch.insert('streets', {
        'id': street['id'],
        'district_id': street['district_id'],
        'name': street['name'],
      });
    }

    for (final wasteType in data['waste_types'] as List<dynamic>) {
      batch.insert('waste_types', {
        'id': wasteType['id'],
        'name': wasteType['name'],
        'est_fee': wasteType['est_fee'],
      });
    }

    for (final user in data['demo_users'] as List<dynamic>) {
      final plainPassword = user['password'] as String;
      batch.insert('users', {
        'full_name': user['full_name'],
        'phone': user['phone'],
        'password_hash': PasswordService.hashPassword(plainPassword),
        'role': user['role'],
        'city_id': user['city_id'],
        'district_id': user['district_id'],
        'street_id': user['street_id'],
        'landmark_note': user['landmark_note'],
        'vehicle_plate': user['vehicle_plate'],
        'vehicle_type': user['vehicle_type'],
        'service_city_id': user['service_city_id'],
      });
    }

    await batch.commit(noResult: true);
  }

  /// Row counts per table — handy for Phase 2 manual testing.
  Future<Map<String, int>> getTableCounts() async {
    final db = await database;
    final tables = [
      'users',
      'cities',
      'districts',
      'streets',
      'waste_types',
      'requests',
      'ratings',
    ];

    final counts = <String, int>{};
    for (final table in tables) {
      final result = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'),
      );
      counts[table] = result ?? 0;
    }
    return counts;
  }

  /// Demo login check — verifies hashed password for a phone number.
  Future<bool> verifyDemoLogin(String phone, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
      limit: 1,
    );
    if (rows.isEmpty) return false;

    final hash = rows.first['password_hash'] as String;
    return PasswordService.verifyPassword(password, hash);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
