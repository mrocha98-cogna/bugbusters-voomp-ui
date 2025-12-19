import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('voomp_sellers.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      return await openDatabase(
        filePath, // Apenas 'voomp_sellers.db'
        version: 1,
        onCreate: _createDB,
      );
    }

    // Mobile/Desktop
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const userSessionTable = '''
      CREATE TABLE user_session (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accessToken TEXT NOT NULL
      )
    ''';

    await db.execute(userSessionTable);
  }

  Future<void> saveToken(String token) async {
    final db = await instance.database;

    await db.delete('user_session');

    await db.insert('user_session', {'accessToken': token});
  }

  Future<String?> getAccessToken() async {
    final db = await instance.database;

    final result = await db.query('user_session', limit: 1);

    if (result.isNotEmpty) {
      return result.first['accessToken'] as String;
    } else {
      return null;
    }
  }

  Future<void> clearSession() async {
    final db = await instance.database;
    await db.delete('user_session');
  }
}
