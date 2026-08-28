class Note {
  final String id;
  final String content;
  final int colorIndex;
  final bool isPinned;
  final DateTime updatedAt;
  final DateTime createdAt;

  const Note({
    required this.id,
    required this.content,
    this.colorIndex = 0,
    this.isPinned = false,
    required this.updatedAt,
    required this.createdAt,
  });

  Note copyWith({
    String? content,
    int? colorIndex,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      content: content ?? this.content,
      colorIndex: colorIndex ?? this.colorIndex,
      isPinned: isPinned ?? this.isPinned,
      updatedAt: updatedAt ?? DateTime.now(),
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'content': content,
      'colorIndex': colorIndex,
      'isPinned': isPinned ? 1 : 0,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as String,
      content: map['content'] as String,
      colorIndex: map['colorIndex'] as int? ?? 0,
      isPinned: (map['isPinned'] as int? ?? 0) == 1,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
