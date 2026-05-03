import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../services/book_service.dart';
import '../services/category_service.dart';
import '../l10n/app_strings.dart';

enum SortMode { updatedDesc, titleAsc, createdDesc }

/// Manages book list logic including filtering, sorting, and smart collections.
class BookListManager {
  final BookService bookService;
  final CategoryService categoryService;
  final TextEditingController searchController;
  
  List<Book> _books = [];
  SortMode _sortMode = SortMode.updatedDesc;
  String? _filterCategoryId;
  
  BookListManager({
    required this.bookService,
    required this.categoryService,
    required this.searchController,
  });

  /// Refreshes the book list from the service.
  void refresh() {
    _books = bookService.getAll();
  }

  /// Gets the current list of books.
  List<Book> get books => _books;

  /// Sets the sort mode.
  void setSortMode(SortMode mode) {
    _sortMode = mode;
  }

  /// Gets the current sort mode.
  SortMode getSortMode() => _sortMode;

  /// Sets the filter category ID.
  void setFilterCategoryId(String? categoryId) {
    _filterCategoryId = categoryId;
  }

  /// Gets the current filter category ID.
  String? getFilterCategoryId() => _filterCategoryId;

  /// Gets filtered and sorted books based on current filters and search.
  List<Book> get filteredAndSorted {
    var result = _books;
    
    // Filter by category
    if (_filterCategoryId != null) {
      result = result.where((b) => b.categoryId == _filterCategoryId).toList();
    }
    
    // Filter by search query
    final query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((b) =>
              b.title.toLowerCase().contains(query) ||
              b.author.toLowerCase().contains(query))
          .toList();
    }
    
    // Sort
    switch (_sortMode) {
      case SortMode.updatedDesc:
        // Already sorted by service (most recent first)
        break;
      case SortMode.titleAsc:
        result = List.of(result)
          ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortMode.createdDesc:
        result = List.of(result)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    return result;
  }

  /// Gets recently added books (within last 7 days).
  List<Book> get recentlyAdded {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _books.where((b) => b.createdAt.isAfter(weekAgo)).toList();
  }

  /// Gets unread books (progress < 10%).
  List<Book> get unreadBooks {
    return _books.where((b) => b.progressPercent < 0.1).toList();
  }

  /// Gets almost finished books (progress >= 70% and < 100%).
  List<Book> get almostFinished {
    return _books.where((b) => b.progressPercent >= 0.7 && b.progressPercent < 1.0).toList();
  }

  /// Gets frequently read books (reading time > 1 hour).
  List<Book> get frequentlyRead {
    return _books.where((b) => b.readingSeconds > 3600).toList();
  }

  /// Gets recently opened books.
  List<Book> getRecentlyOpened({int limit = 5}) {
    return bookService.getRecentlyOpened(limit: limit);
  }

  /// Deletes a book with undo functionality.
  Future<void> deleteBook(BuildContext context, Book book) async {
    final s = AppStrings.of(context);
    await bookService.delete(book.id);
    
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.bookDeleted(book.title)),
        action: SnackBarAction(
          label: s.undo,
          onPressed: () async {
            await bookService.restore(book);
          },
        ),
      ),
    );
  }

  /// Shows a confirmation dialog for deleting a book.
  Future<bool?> showDeleteConfirmation(BuildContext context, Book book) async {
    final s = AppStrings.of(context);
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteBook),
        content: Text(s.deleteBookConfirm(book.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }

  /// Gets all categories for filtering.
  List<Category> getCategories() {
    return categoryService.getAll();
  }

  /// Builds a sort menu item widget.
  PopupMenuItem<SortMode> buildSortMenuItem(
    BuildContext context,
    SortMode mode,
    String label,
  ) {
    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          if (_sortMode == mode)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check, size: 18),
            ),
          Text(label),
        ],
      ),
    );
  }

  /// Builds category filter chips.
  List<Widget> buildCategoryFilterChips(BuildContext context) {
    final s = AppStrings.of(context);
    final categories = getCategories();
    
    if (categories.isEmpty) return [];
    
    final chips = <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(s.all),
          selected: _filterCategoryId == null,
          onSelected: (_) => _filterCategoryId = null,
        ),
      ),
    ];
    
    chips.addAll(categories.map((cat) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: CircleAvatar(
          radius: 6,
          backgroundColor: Color(cat.colorValue),
        ),
        label: Text(cat.name),
        selected: _filterCategoryId == cat.id,
        onSelected: (_) => _filterCategoryId = _filterCategoryId == cat.id ? null : cat.id,
      ),
    )));
    
    return chips;
  }

  /// Checks if smart collections should be shown.
  bool shouldShowSmartCollections(String searchText, String? categoryId) {
    return searchText.isEmpty && categoryId == null;
  }

  /// Gets smart collections data.
  List<SmartCollectionData> getSmartCollections() {
    return [
      SmartCollectionData(
        title: 'Recently Added',
        books: recentlyAdded,
        icon: Icons.new_releases,
      ),
      SmartCollectionData(
        title: 'Unread',
        books: unreadBooks,
        icon: Icons.bookmark_border,
      ),
      SmartCollectionData(
        title: 'Almost Finished',
        books: almostFinished,
        icon: Icons.trending_up,
      ),
      SmartCollectionData(
        title: 'Frequently Read',
        books: frequentlyRead,
        icon: Icons.star,
      ),
    ];
  }
}

/// Data for a smart collection card.
class SmartCollectionData {
  final String title;
  final List<Book> books;
  final IconData icon;
  final Color? color;

  SmartCollectionData({
    required this.title,
    required this.books,
    required this.icon,
    this.color,
  });

  int get count => books.length;
}