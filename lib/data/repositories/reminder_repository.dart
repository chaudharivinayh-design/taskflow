import '../db/database_helper.dart';
import '../models/reminder.dart';

class ReminderRepository {
  final _dbHelper = DatabaseHelper.instance;
  static const _table = 'reminders';

  Future<List<Reminder>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, orderBy: 'dateTime ASC');
    return rows.map(Reminder.fromMap).toList();
  }

  Future<void> insert(Reminder reminder) async {
    final db = await _dbHelper.database;
    await db.insert(_table, reminder.toMap());
  }

  Future<void> update(Reminder reminder) async {
    final db = await _dbHelper.database;
    await db.update(_table, reminder.toMap(),
        where: 'id = ?', whereArgs: [reminder.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
