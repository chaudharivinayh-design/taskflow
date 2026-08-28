import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/note.dart';
import '../../providers/note_provider.dart';

const _noteColors = [
  Color(0xFFFFF3C4),
  Color(0xFFD7F5DC),
  Color(0xFFD7E8FF),
  Color(0xFFFFE0EC),
  Color(0xFFE7DBFF),
];

class NoteEditScreen extends StatefulWidget {
  final Note? existing;
  const NoteEditScreen({super.key, this.existing});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late final TextEditingController _ctrl;
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.existing?.content ?? '');
    _colorIndex = widget.existing?.colorIndex ?? 0;
  }

  void _save() {
    final content = _ctrl.text.trim();
    if (content.isEmpty) return;
    final provider = context.read<NoteProvider>();
    if (widget.existing == null) {
      provider.addNote(content, colorIndex: _colorIndex);
    } else {
      provider.updateNote(widget.existing!.copyWith(
        content: content,
        colorIndex: _colorIndex,
        updatedAt: DateTime.now(),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      backgroundColor: _noteColors[_colorIndex].withOpacity(0.5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                autofocus: !isEditing,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Write your note...',
                  border: InputBorder.none,
                  filled: false,
                ),
                style: const TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(_noteColors.length, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _colorIndex = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _noteColors[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _colorIndex == i
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<NoteProvider>().deleteNote(widget.existing!.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Note'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
