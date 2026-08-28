import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/note.dart';
import '../data/repositories/note_repository.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repo = NoteRepository();
  final _uuid = const Uuid();
  List<Note> _notes = [];
  bool _loading = true;

  List<Note> get notes => List.unmodifiable(_notes);
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _notes = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> addNote(String content, {int colorIndex = 0}) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      content: content,
      colorIndex: colorIndex,
      createdAt: now,
      updatedAt: now,
    );
    _notes.insert(0, note);
    notifyListeners();
    await _repo.insert(note);
  }

  Future<void> updateNote(Note note) async {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      _notes[idx] = note;
      notifyListeners();
    }
    await _repo.update(note);
  }

  Future<void> togglePin(Note note) async {
    await updateNote(note.copyWith(isPinned: !note.isPinned));
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    await _repo.delete(id);
  }
}
