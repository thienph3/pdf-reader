import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/main.dart';
import 'package:pdf_reader/services/book_service.dart';
import 'package:pdf_reader/services/category_service.dart';
import 'package:pdf_reader/services/settings_service.dart';
import 'package:pdf_reader/services/thumbnail_service.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    final bookSvc = BookService();
    await bookSvc.init();
    final catSvc = CategoryService();
    await catSvc.init();
    final settingsSvc = SettingsService();
    await settingsSvc.init();
    final thumbSvc = ThumbnailService();
    await tester.pumpWidget(PdfReaderApp(
      bookService: bookSvc,
      categoryService: catSvc,
      settingsService: settingsSvc,
      thumbnailService: thumbSvc,
    ));
    expect(find.text('PDF Reader'), findsOneWidget);
  });
}
