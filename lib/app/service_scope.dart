import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/book_service.dart';
import '../services/category_service.dart';
import '../services/reading_log_service.dart';
import '../services/settings_service.dart';
import '../services/thumbnail_service.dart';
import '../services/tts_service.dart';
import '../services/ocr_service.dart';
import '../services/highlight_service.dart';
import '../services/streak_service.dart';
import '../services/book_settings_service.dart';
import '../services/page_notes_service.dart';
import '../services/reading_queue_service.dart';

class BookServiceScope {
  static BookService of(BuildContext context) => Provider.of<BookService>(context, listen: false);
}

class CategoryServiceScope {
  static CategoryService of(BuildContext context) => Provider.of<CategoryService>(context, listen: false);
}

class ThumbnailServiceScope {
  static ThumbnailService of(BuildContext context) => Provider.of<ThumbnailService>(context, listen: false);
}

class ReadingLogServiceScope {
  static ReadingLogService of(BuildContext context) => Provider.of<ReadingLogService>(context, listen: false);
}

class TtsServiceScope {
  static TtsService of(BuildContext context) => Provider.of<TtsService>(context, listen: false);
}

class OcrServiceScope {
  static OcrService of(BuildContext context) => Provider.of<OcrService>(context, listen: false);
}

class HighlightServiceScope {
  static HighlightService of(BuildContext context) => Provider.of<HighlightService>(context, listen: false);
}

class StreakServiceScope {
  static StreakService of(BuildContext context) => Provider.of<StreakService>(context, listen: false);
}

class SettingsScope {
  static SettingsService of(BuildContext context) => Provider.of<SettingsService>(context);
}

class BookSettingsServiceScope {
  static BookSettingsService of(BuildContext context) => Provider.of<BookSettingsService>(context, listen: false);
}

class PageNotesServiceScope {
  static PageNotesService of(BuildContext context) => Provider.of<PageNotesService>(context, listen: false);
}

class ReadingQueueServiceScope {
  static ReadingQueueService of(BuildContext context) => Provider.of<ReadingQueueService>(context, listen: false);
}
