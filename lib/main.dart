import 'package:flutter/material.dart';
import 'services/book_service.dart';
import 'services/thumbnail_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bookService = BookService();
  await bookService.init();
  final thumbnailService = ThumbnailService();
  runApp(PdfReaderApp(
    bookService: bookService,
    thumbnailService: thumbnailService,
  ));
}

class BookServiceScope extends InheritedWidget {
  final BookService bookService;

  const BookServiceScope({
    super.key,
    required this.bookService,
    required super.child,
  });

  static BookService of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<BookServiceScope>()!
        .bookService;
  }

  @override
  bool updateShouldNotify(BookServiceScope oldWidget) =>
      bookService != oldWidget.bookService;
}

class ThumbnailServiceScope extends InheritedWidget {
  final ThumbnailService thumbnailService;

  const ThumbnailServiceScope({
    super.key,
    required this.thumbnailService,
    required super.child,
  });

  static ThumbnailService of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThumbnailServiceScope>()!
        .thumbnailService;
  }

  @override
  bool updateShouldNotify(ThumbnailServiceScope oldWidget) =>
      thumbnailService != oldWidget.thumbnailService;
}

class PdfReaderApp extends StatelessWidget {
  final BookService bookService;
  final ThumbnailService thumbnailService;

  const PdfReaderApp({
    super.key,
    required this.bookService,
    required this.thumbnailService,
  });

  @override
  Widget build(BuildContext context) {
    return BookServiceScope(
      bookService: bookService,
      child: ThumbnailServiceScope(
        thumbnailService: thumbnailService,
        child: MaterialApp(
          title: 'PDF Reader',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
