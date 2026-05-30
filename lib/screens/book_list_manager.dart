import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../services/book_service.dart';
import '../services/category_service.dart';
import '../l10n/app_strings.dart';
import 'book_smart_collections.dart';

enum SortMode { updatedDesc, titleAsc, createdDesc }
enum SmartFilter { none, recentlyAdded, unread, almostFinished, frequentlyRead }

/// Manages book list logic including filtering, sorting, and smart collections.
class BookListManager with BookSmartCollections {
  final BookService bookService;
  final CategoryService categoryService;
  final TextEditingController searchController;

  List<Book> _books = [];
  SortMode _sortMode = SortMode.updatedDesc;
  String? _filterCategoryId;
  SmartFilter _smartFilter = SmartFilter.none;

  BookListManager({required this.bookService, required this.categoryService, required this.searchController});

  void refresh() { _books = bookService.getAll(); }
  @override
  List<Book> get books => _books;
  void setSortMode(SortMode mode) { _sortMode = mode; }
  SortMode getSortMode() => _sortMode;
  void setFilterCategoryId(String? categoryId) { _filterCategoryId = categoryId; }
  String? getFilterCategoryId() => _filterCategoryId;
  void setSmartFilter(SmartFilter filter) { _smartFilter = filter; }
  SmartFilter get smartFilter => _smartFilter;

  List<Book> get filteredAndSorted {
    var result = _books;
    if (_filterCategoryId != null) result = result.where((b) => b.categoryId == _filterCategoryId).toList();
    switch (_smartFilter) {
      case SmartFilter.none: break;
      case SmartFilter.recentlyAdded:
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        result = result.where((b) => b.createdAt.isAfter(weekAgo)).toList();
      case SmartFilter.unread: result = result.where((b) => b.progressPercent < 0.1).toList();
      case SmartFilter.almostFinished: result = result.where((b) => b.progressPercent >= 0.7 && b.progressPercent < 1.0).toList();
      case SmartFilter.frequentlyRead: result = result.where((b) => b.readingSeconds > 3600).toList();
    }
    final query = searchController.text.toLowerCase();
    if (query.isNotEmpty && _smartFilter == SmartFilter.none) {
      result = result.where((b) => b.title.toLowerCase().contains(query) || b.author.toLowerCase().contains(query)).toList();
    }
    switch (_sortMode) {
      case SortMode.updatedDesc: break;
      case SortMode.titleAsc: result = List.of(result)..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SortMode.createdDesc: result = List.of(result)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  List<Book> getRecentlyOpened({int limit = 5}) => bookService.getRecentlyOpened(limit: limit);

  Future<void> deleteBook(BuildContext context, Book book) async {
    final s = AppStrings.of(context);
    await bookService.delete(book.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(s.bookDeleted(book.title)),
      action: SnackBarAction(label: s.undo, onPressed: () async { await bookService.restore(book); }),
    ));
  }

  Future<bool?> showDeleteConfirmation(BuildContext context, Book book) async {
    final s = AppStrings.of(context);
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteBook),
        content: Text(s.deleteBookConfirm(book.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
        ],
      ),
    );
  }

  List<Category> getCategories() => categoryService.getAll();

  PopupMenuItem<SortMode> buildSortMenuItem(BuildContext context, SortMode mode, String label) {
    return PopupMenuItem(value: mode, child: Row(children: [
      if (_sortMode == mode) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.check, size: 18)),
      Text(label),
    ]));
  }

  List<Widget> buildCategoryFilterChips(BuildContext context, {VoidCallback? onChanged}) {
    final s = AppStrings.of(context);
    final categories = getCategories();
    if (categories.isEmpty) return [];
    final chips = <Widget>[
      Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(label: Text(s.all), selected: _filterCategoryId == null, onSelected: (_) { _filterCategoryId = null; onChanged?.call(); })),
    ];
    chips.addAll(categories.map((cat) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(avatar: CircleAvatar(radius: 6, backgroundColor: Color(cat.colorValue)), label: Text(cat.name), selected: _filterCategoryId == cat.id, onSelected: (_) { _filterCategoryId = _filterCategoryId == cat.id ? null : cat.id; onChanged?.call(); }),
    )));
    return chips;
  }

  bool shouldShowSmartCollections(String searchText, String? categoryId) {
    return searchText.isEmpty && categoryId == null && _smartFilter == SmartFilter.none;
  }
}
