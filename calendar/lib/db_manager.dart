import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseManager {
  late final Database db;

  DatabaseManager() {
    _initDB();
  }

  Future<void> _initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'events.db');
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE Events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            rangeStart TEXT,
            rangeEnd TEXT,
            timeRangeStart TEXT,
            timeRangeEnd TEXT
          )
        ''');
      },
    );
  }

  Future<String> getDatabasePath() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'events.db');
    return path;
  }
}
