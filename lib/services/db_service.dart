import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:domain_investigator/models/whois_history.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('whois_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE history (
  id $idType,
  domain $textType,
  data $textType,
  timestamp $textType
  )
''');
  }

  Future<WhoisHistory> insertHistory(WhoisHistory history) async {
    final db = await instance.database;

    // Check if domain already exists
    final maps = await db.query(
      'history',
      columns: ['id'],
      where: 'domain = ?',
      whereArgs: [history.domain],
    );

    if (maps.isNotEmpty) {
      // Update existing record to have the new content & latest timestamp
      final int id = maps.first['id'] as int;
      await db.update(
        'history',
        history.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      return WhoisHistory(
        id: id,
        domain: history.domain,
        data: history.data,
        timestamp: history.timestamp,
      );
    } else {
      // Insert new
      final id = await db.insert('history', history.toMap());
      return WhoisHistory(
        id: id,
        domain: history.domain,
        data: history.data,
        timestamp: history.timestamp,
      );
    }
  }

  Future<List<WhoisHistory>> getAllHistory() async {
    final db = await instance.database;
    const orderBy = 'timestamp DESC';
    final result = await db.query('history', orderBy: orderBy);

    return result.map((json) => WhoisHistory.fromMap(json)).toList();
  }

  Future<int> clearAllHistory() async {
    final db = await instance.database;
    return await db.delete('history');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
