import '../db/database_helper.dart';
import '../models/task.dart';

class TaskRepository {
  final _dbHelper = DatabaseHelper.instance;
  static const _table = 'tasks';

  Future<List<Task>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, orderBy: 'createdAt DESC');
    return rows.map(Task.fromMap).toList();
  }

  Future<void> insert(Task task) async {
    final db = await _dbHelper.database;
    await db.insert(_table, task.toMap());
  }

  Future<void> update(Task task) async {
    final db = await _dbHelper.database;
    await db.update(_table, task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
