import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseManager{
  


  Future<String> getDatabasePath() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'events.db');
    return path;
  }
}