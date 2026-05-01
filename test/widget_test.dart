import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/main.dart';
import 'package:pdf_reader/services/book_service.dart';
import 'package:pdf_reader/services/thumbnail_service.dart';

void main() {
  testWidgets('App renders book list screen', (WidgetTester tester) async {
    final svc = BookService();
    await svc.init();
    final thumbSvc = ThumbnailService();
    await tester.pumpWidget(PdfReaderApp(
      bookService: svc,
      thumbnailService: thumbSvc,
    ));
    expect(find.text('Thư viện sách'), findsOneWidget);
  });
}
