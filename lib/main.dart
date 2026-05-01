import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_strings.dart';
import 'services/book_service.dart';
import 'services/category_service.dart';
import 'services/settings_service.dart';
import 'services/thumbnail_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bookService = BookService();
  await bookService.init();
  final categoryService = CategoryService();
  await categoryService.init();
  final settingsService = SettingsService();
  await settingsService.init();
  final thumbnailService = ThumbnailService();
  runApp(PdfReaderApp(
    bookService: bookService,
    categoryService: categoryService,
    settingsService: settingsService,
    thumbnailService: thumbnailService,
  ));
}

class BookServiceScope extends InheritedWidget {
  final BookService bookService;
  const BookServiceScope({super.key, required this.bookService, required super.child});
  static BookService of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BookServiceScope>()!.bookService;
  @override
  bool updateShouldNotify(BookServiceScope oldWidget) => bookService != oldWidget.bookService;
}

class CategoryServiceScope extends InheritedWidget {
  final CategoryService categoryService;
  const CategoryServiceScope({super.key, required this.categoryService, required super.child});
  static CategoryService of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CategoryServiceScope>()!.categoryService;
  @override
  bool updateShouldNotify(CategoryServiceScope oldWidget) => categoryService != oldWidget.categoryService;
}

class ThumbnailServiceScope extends InheritedWidget {
  final ThumbnailService thumbnailService;
  const ThumbnailServiceScope({super.key, required this.thumbnailService, required super.child});
  static ThumbnailService of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThumbnailServiceScope>()!.thumbnailService;
  @override
  bool updateShouldNotify(ThumbnailServiceScope oldWidget) => thumbnailService != oldWidget.thumbnailService;
}

class PdfReaderApp extends StatefulWidget {
  final BookService bookService;
  final CategoryService categoryService;
  final SettingsService settingsService;
  final ThumbnailService thumbnailService;

  const PdfReaderApp({
    super.key,
    required this.bookService,
    required this.categoryService,
    required this.settingsService,
    required this.thumbnailService,
  });

  @override
  State<PdfReaderApp> createState() => _PdfReaderAppState();
}

class _PdfReaderAppState extends State<PdfReaderApp> {
  @override
  void initState() {
    super.initState();
    widget.settingsService.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    widget.settingsService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final settings = widget.settingsService;

    return BookServiceScope(
      bookService: widget.bookService,
      child: CategoryServiceScope(
        categoryService: widget.categoryService,
        child: ThumbnailServiceScope(
          thumbnailService: widget.thumbnailService,
          child: SettingsScope(
            settingsService: settings,
            child: MaterialApp(
              title: 'PDF Reader',
              debugShowCheckedModeBanner: false,
              themeMode: settings.themeMode,
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
              locale: settings.locale,
              supportedLocales: const [Locale('vi'), Locale('en')],
              localizationsDelegates: const [
                AppStringsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsScope extends InheritedWidget {
  final SettingsService settingsService;
  const SettingsScope({super.key, required this.settingsService, required super.child});
  static SettingsService of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.settingsService;
  @override
  bool updateShouldNotify(SettingsScope oldWidget) => settingsService != oldWidget.settingsService;
}
