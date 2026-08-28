import '../db/database_helper.dart';
import '../models/alarm.dart';

class AlarmRepository {
  final _dbHelper = DatabaseHelper.instance;
  static const _table = 'alarms';

  Future<List<Alarm>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, orderBy: 'hour ASC, minute ASC');
    return rows.map(Alarm.fromMap).toList();
  }

  Future<void> insert(Alarm alarm) async {
    final db = await _dbHelper.database;
    await db.insert(_table, alarm.toMap());
  }

  Future<void> update(Alarm alarm) async {
    final db = await _dbHelper.database;
    await db.update(_table, alarm.toMap(), where: 'id = ?', whereArgs: [alarm.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
