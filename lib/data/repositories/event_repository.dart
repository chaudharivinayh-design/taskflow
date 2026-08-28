import '../db/database_helper.dart';
import '../models/event.dart';

class EventRepository {
  final _dbHelper = DatabaseHelper.instance;
  static const _table = 'events';

  Future<List<Event>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, orderBy: 'start ASC');
    return rows.map(Event.fromMap).toList();
  }

  Future<void> insert(Event event) async {
    final db = await _dbHelper.database;
    await db.insert(_table, event.toMap());
  }

  Future<void> update(Event event) async {
    final db = await _dbHelper.database;
    await db.update(_table, event.toMap(), where: 'id = ?', whereArgs: [event.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
