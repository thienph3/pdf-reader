import 'dart:convert';

/// Book format types.
enum BookFormat { paper, ebook, both }

/// A bookmark on a specific page with optional note.
class Bookmark {
  final int page;
  final String note;
  final DateTime createdAt;

  const Bookmark({
    required this.page,
    this.note = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'page': page,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Bookmark.fromMap(Map<dynamic, dynamic> map) => Bookmark(
        page: map['page'] as int,
        note: map['note'] as String? ?? '',
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

class Book {
  final String id;
  final String title;
  final String author;
  final BookFormat format;
  final String? filePath;
  final String notes;
  final int lastPage;
  final int totalPages;
  final int readingSeconds; // cumulative reading time
  final List<Bookmark> bookmarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Book({
    required this.id,
    required this.title,
    this.author = '',
    this.format = BookFormat.paper,
    this.filePath,
    this.notes = '',
    this.lastPage = 0,
    this.totalPages = 0,
    this.readingSeconds = 0,
    this.bookmarks = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasEbook => format == BookFormat.ebook || format == BookFormat.both;
  bool get canRead => hasEbook && filePath != null && filePath!.isNotEmpty;

  double get progressPercent =>
      totalPages > 0 ? ((lastPage + 1) / totalPages).clamp(0.0, 1.0) : 0.0;

  String get readingTimeFormatted {
    if (readingSeconds < 60) return '${readingSeconds}s';
    final m = readingSeconds ~/ 60;
    final h = m ~/ 60;
    if (h > 0) return '${h}h ${m % 60}m';
    return '${m}m';
  }

  Book copyWith({
    String? title,
    String? author,
    BookFormat? format,
    String? Function()? filePath,
    String? notes,
    int? lastPage,
    int? totalPages,
    int? readingSeconds,
    List<Bookmark>? bookmarks,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      format: format ?? this.format,
      filePath: filePath != null ? filePath() : this.filePath,
      notes: notes ?? this.notes,
      lastPage: lastPage ?? this.lastPage,
      totalPages: totalPages ?? this.totalPages,
      readingSeconds: readingSeconds ?? this.readingSeconds,
      bookmarks: bookmarks ?? this.bookmarks,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'author': author,
        'format': format.index,
        'filePath': filePath,
        'notes': notes,
        'lastPage': lastPage,
        'totalPages': totalPages,
        'readingSeconds': readingSeconds,
        'bookmarks': bookmarks.map((b) => b.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Book.fromMap(Map<dynamic, dynamic> map) => Book(
        id: map['id'] as String,
        title: map['title'] as String,
        author: map['author'] as String? ?? '',
        format: BookFormat.values[map['format'] as int? ?? 0],
        filePath: map['filePath'] as String?,
        notes: map['notes'] as String? ?? '',
        lastPage: map['lastPage'] as int? ?? 0,
        totalPages: map['totalPages'] as int? ?? 0,
        readingSeconds: map['readingSeconds'] as int? ?? 0,
        bookmarks: (map['bookmarks'] as List?)
                ?.map((b) => Bookmark.fromMap(b as Map))
                .toList() ??
            [],
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  /// JSON string for export/import.
  String toJson() => jsonEncode(toMap());
  factory Book.fromJson(String json) =>
      Book.fromMap(jsonDecode(json) as Map<String, dynamic>);
}
