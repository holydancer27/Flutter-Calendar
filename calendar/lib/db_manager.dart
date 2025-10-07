import 'package:calendar/extras.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:table_calendar/table_calendar.dart';

class DatabaseManager {
  static Database? _db;

  DatabaseManager();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'events.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE Events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
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

  // Insert a new event
  Future<int> insertEvent(Event event) async {
    final db = await database;
    return await db.insert('Events', event.toMap());
  }

  // Get all events
  Future<List<Event>> getEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Events');
    return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
  }

  // Delete an event
  Future<void> deleteEvent(int id) async {
    final db = await database;
    await db.delete('Events', where: 'id = ?', whereArgs: [id]);
  }

  // Load events into the events map
  Future<void> loadEventsIntoMap() async {
    final List<Event> eventList = await getEvents();
    events.clear();

    for (final event in eventList) {
      if (event.rangeStart != null && event.rangeEnd != null) {
        // Multi-day event
        final normalizedStart = normalizeDate(event.rangeStart!);
        final normalizedEnd = normalizeDate(event.rangeEnd!);

        // Add to start date
        if (events[normalizedStart] != null) {
          events[normalizedStart]!.add(event);
        } else {
          events[normalizedStart] = [event];
        }

        // Add to end date
        if (events[normalizedEnd] != null) {
          events[normalizedEnd]!.add(event);
        } else {
          events[normalizedEnd] = [event];
        }
      } else {
        // Single day event - use rangeStart if available, otherwise we need to handle this case
        // Note: You might want to add a specific date field for single day events
        final date =
            event.rangeStart ??
            DateTime.now(); // Fallback, you should adjust this
        final normalized = normalizeDate(date);

        if (events[normalized] != null) {
          events[normalized]!.add(event);
        } else {
          events[normalized] = [event];
        }
      }
    }
  }

  Future<String> getDatabasePath() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'events.db');
    return path;
  }
}
