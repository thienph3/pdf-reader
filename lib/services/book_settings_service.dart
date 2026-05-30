import 'package:hive_flutter/hive_flutter.dart';

class BookSettings {
  final int readingMode;
  final bool horizontalScroll;
  final bool cropMargins;
  final double brightness; // -1 = use system

  const BookSettings({
    this.readingMode = 0,
    this.horizontalScroll = false,
    this.cropMargins = false,
    this.brightness = -1,
  });

  BookSettings copyWith({
    int? readingMode,
    bool? horizontalScroll,
    bool? cropMargins,
    double? brightness,
  }) =>
      BookSettings(
        readingMode: readingMode ?? this.readingMode,
        horizontalScroll: horizontalScroll ?? this.horizontalScroll,
        cropMargins: cropMargins ?? this.cropMargins,
        brightness: brightness ?? this.brightness,
      );

  Map<String, dynamic> toMap() => {
        'readingMode': readingMode,
        'horizontalScroll': horizontalScroll,
        'cropMargins': cropMargins,
        'brightness': brightness,
      };

  factory BookSettings.fromMap(Map map) => BookSettings(
        readingMode: map['readingMode'] as int? ?? 0,
        horizontalScroll: map['horizontalScroll'] as bool? ?? false,
        cropMargins: map['cropMargins'] as bool? ?? false,
        brightness: (map['brightness'] as num?)?.toDouble() ?? -1,
      );
}

class BookSettingsService {
  late Box<Map> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Map>('book_settings');
  }

  BookSettings getSettings(String bookId) {
    final map = _box.get(bookId);
    if (map == null) return const BookSettings();
    return BookSettings.fromMap(map);
  }

  Future<void> saveSettings(String bookId, BookSettings settings) async {
    await _box.put(bookId, settings.toMap());
  }
}
