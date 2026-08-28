import '../db/database_helper.dart';
import '../models/note.dart';

class NoteRepository {
  final _dbHelper = DatabaseHelper.instance;
  static const _table = 'notes';

  Future<List<Note>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, orderBy: 'isPinned DESC, updatedAt DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<void> insert(Note note) async {
    final db = await _dbHelper.database;
    await db.insert(_table, note.toMap());
  }

  Future<void> update(Note note) async {
    final db = await _dbHelper.database;
    await db.update(_table, note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
