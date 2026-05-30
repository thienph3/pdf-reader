enum AnnotationType { highlight, underline, strikethrough }

/// A persistent text highlight on a specific page.
class Highlight {
  final String id;
  final int page;
  final int startIndex;
  final int endIndex;
  final String text; // the highlighted text content
  final int colorValue; // highlight color
  final String note;
  final DateTime createdAt;
  final AnnotationType type;

  const Highlight({
    required this.id,
    required this.page,
    required this.startIndex,
    required this.endIndex,
    required this.text,
    this.colorValue = 0x80FFEB3B, // semi-transparent yellow
    this.note = '',
    required this.createdAt,
    this.type = AnnotationType.highlight,
  });

  Highlight copyWith({int? colorValue, String? note, AnnotationType? type}) => Highlight(
        id: id,
        page: page,
        startIndex: startIndex,
        endIndex: endIndex,
        text: text,
        colorValue: colorValue ?? this.colorValue,
        note: note ?? this.note,
        createdAt: createdAt,
        type: type ?? this.type,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'page': page,
        'startIndex': startIndex,
        'endIndex': endIndex,
        'text': text,
        'colorValue': colorValue,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'type': type.index,
      };

  factory Highlight.fromMap(Map<dynamic, dynamic> map) => Highlight(
        id: map['id'] as String,
        page: map['page'] as int,
        startIndex: map['startIndex'] as int,
        endIndex: map['endIndex'] as int,
        text: map['text'] as String? ?? '',
        colorValue: map['colorValue'] as int? ?? 0x80FFEB3B,
        note: map['note'] as String? ?? '',
        createdAt: DateTime.parse(map['createdAt'] as String),
        type: AnnotationType.values[(map['type'] as int?) ?? 0],
      );
}
