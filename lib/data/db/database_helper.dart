import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Single source of truth for the local SQLite database.
/// All repositories share this connection. Offline-first: every write
/// lands here first, the UI is driven purely from these tables.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const _dbName = 'taskflow.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        notes TEXT,
        dueDate INTEGER,
        priority TEXT NOT NULL,
        repeat TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        notes TEXT,
        dateTime INTEGER NOT NULL,
        repeat TEXT NOT NULL,
        isActive INTEGER NOT NULL,
        snoozeMinutes INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE alarms (
        id TEXT PRIMARY KEY,
        label TEXT NOT NULL,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        repeatDays TEXT NOT NULL,
        isEnabled INTEGER NOT NULL,
        vibrate INTEGER NOT NULL,
        soundAsset TEXT NOT NULL,
        snoozeMinutes INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        colorIndex INTEGER NOT NULL,
        isPinned INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        emoji TEXT NOT NULL,
        targetWeekdays TEXT NOT NULL,
        completedDates TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        location TEXT,
        start INTEGER NOT NULL,
        end INTEGER,
        allDay INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_tasks_due ON tasks (dueDate)');
    await db.execute('CREATE INDEX idx_reminders_dt ON reminders (dateTime)');
    await db.execute('CREATE INDEX idx_events_start ON events (start)');
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
