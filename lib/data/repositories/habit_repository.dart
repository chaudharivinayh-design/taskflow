import '../db/database_helper.dart';
import '../models/habit.dart';

class HabitRepository {
  final _dbHelper = DatabaseHelper.instance;
  static const _table = 'habits';

  Future<List<Habit>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, orderBy: 'createdAt DESC');
    return rows.map(Habit.fromMap).toList();
  }

  Future<void> insert(Habit habit) async {
    final db = await _dbHelper.database;
    await db.insert(_table, habit.toMap());
  }

  Future<void> update(Habit habit) async {
    final db = await _dbHelper.database;
    await db.update(_table, habit.toMap(), where: 'id = ?', whereArgs: [habit.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
