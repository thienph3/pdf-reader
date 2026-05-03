import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/main.dart';
import 'package:pdf_reader/services/book_service.dart';
import 'package:pdf_reader/services/category_service.dart';
import 'package:pdf_reader/services/reading_log_service.dart';
import 'package:pdf_reader/services/settings_service.dart';
import 'package:pdf_reader/services/thumbnail_service.dart';
import 'package:pdf_reader/services/tts_service.dart';
import 'package:pdf_reader/services/ocr_service.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    final bookSvc = BookService();
    await bookSvc.init();
    final catSvc = CategoryService();
    await catSvc.init();
    final settingsSvc = SettingsService();
    await settingsSvc.init();
    final logSvc = ReadingLogService();
    await logSvc.init();
    final thumbSvc = ThumbnailService();
    final ttsSvc = TtsService();
    final ocrSvc = OcrService();
    await tester.pumpWidget(PdfReaderApp(
      bookService: bookSvc,
      categoryService: catSvc,
      settingsService: settingsSvc,
      readingLogService: logSvc,
      thumbnailService: thumbSvc,
      ttsService: ttsSvc,
      ocrService: ocrSvc,
    ));
    expect(find.text('PDF Reader'), findsOneWidget);
  });
}
