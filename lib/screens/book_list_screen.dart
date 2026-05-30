import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import '../main.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/category_service.dart';
import '../l10n/app_strings.dart';
import '../utils/annotation_export.dart';
import 'book_actions.dart';
import 'book_list_manager.dart';
import 'book_actions_manager.dart';
import 'book_list_ui.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  bool _isSearching = false;
  bool _initialized = false;
  bool _isGridView = true;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};
  
  final TextEditingController _searchCtrl = TextEditingController();
  
  // Managers
  late BookListManager _listManager;
  late BookActionsManager _actionsManager;
  
  BookService get _bookService => BookServiceScope.of(context);
  CategoryService get _catService => CategoryServiceScope.of(context);

  @override
  void initState() {
    super.initState();
    // Don't initialize managers here - wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      
      // Initialize managers here, after context is available
      _listManager = BookListManager(
        bookService: _bookService,
        categoryService: _catService,
        searchController: _searchCtrl,
      );
      
      _actionsManager = BookActionsManager(bookService: _bookService);
      
      _refresh();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    _listManager.refresh();
    setState(() {});
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchCtrl.clear();
    });
  }

  Future<void> _handleDeleteBook(BuildContext context, Book book) async {
    await _listManager.deleteBook(context, book);
    _refresh();
  }

  Future<void> _handleOpenBook(Book book) async {
    await _actionsManager.openBook(
      context,
      book,
      validateBookPath: validateBookPath,
      onRefresh: _refresh,
    );
  }

  Future<void> _handleAddBook() async {
    await _actionsManager.addBook(
      context,
      onRefresh: _refresh,
    );
  }

  Future<void> _handleEditBook(Book book) async {
    await _actionsManager.editBook(
      context,
      book,
      onRefresh: _refresh,
    );
  }

  Future<void> _handleConfirmDeleteBook(Book book) async {
    await _actionsManager.confirmAndDeleteBook(
      context,
      book,
      onDelete: _handleDeleteBook,
    );
  }

  Future<void> _handleExport() async {
    await _actionsManager.exportBooks(
      context,
      exportFunction: exportBooks,
    );
  }

  Future<void> _handleImport() async {
    await _actionsManager.importBooks(
      context,
      importFunction: (context, bookService) => importBooks(context, bookService),
      onRefresh: _refresh,
    );
  }

  Future<void> _handleExportAnnotations(Book book) async {
    final s = AppStrings.of(context);
    if (book.highlights.isEmpty && book.bookmarks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.noAnnotations)),
      );
      return;
    }
    final md = exportAnnotationsAsMarkdown(book);
    final path = await FilePicker.saveFile(
      dialogTitle: s.exportAnnotations,
      fileName: '${book.title}_annotations.md',
    );
    if (path == null) return;
    await io.File(path).writeAsString(md);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.exportAnnotationsSuccess)),
      );
    }
  }

  void _handleSmartCollectionTap(String title, int bookCount) {
    _filterBySmartCollection(title);
  }

  void _filterBySmartCollection(String collectionTitle) {
    setState(() {
      _searchCtrl.text = '';
      _listManager.setFilterCategoryId(null);
      
      switch (collectionTitle) {
        case 'Recently Added':
          _listManager.setSmartFilter(SmartFilter.recentlyAdded);
        case 'Unread':
          _listManager.setSmartFilter(SmartFilter.unread);
        case 'Almost Finished':
          _listManager.setSmartFilter(SmartFilter.almostFinished);
        case 'Frequently Read':
          _listManager.setSmartFilter(SmartFilter.frequentlyRead);
      }
    });
  }

  String _getDisplayTitle(AppStrings s) {
    switch (_listManager.smartFilter) {
      case SmartFilter.recentlyAdded:
        return s.recentlyAdded;
      case SmartFilter.unread:
        return s.unreadBooks;
      case SmartFilter.almostFinished:
        return s.almostFinished;
      case SmartFilter.frequentlyRead:
        return s.frequentlyRead;
      case SmartFilter.none:
        break;
    }
    
    if (_listManager.getFilterCategoryId() != null) {
      final catId = _listManager.getFilterCategoryId();
      if (catId != null) {
        final catService = CategoryServiceScope.of(context);
        final cat = catService.getById(catId);
        if (cat != null) return cat.name;
      }
    }
    
    return s.library;
  }

  bool get _hasActiveFilter {
    return _listManager.smartFilter != SmartFilter.none ||
        _listManager.getFilterCategoryId() != null;
  }

  void _clearFilter() {
    setState(() {
      _searchCtrl.clear();
      _listManager.setFilterCategoryId(null);
      _listManager.setSmartFilter(SmartFilter.none);
    });
  }

  void _enterSelectionMode(String bookId) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(bookId);
    });
  }

  void _toggleSelection(String bookId) {
    setState(() {
      if (_selectedIds.contains(bookId)) {
        _selectedIds.remove(bookId);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(bookId);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _deleteSelected() async {
    final s = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteBook),
        content: Text('Delete ${_selectedIds.length} books?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
        ],
      ),
    );
    if (confirmed != true) return;
    for (final id in _selectedIds) {
      await _bookService.delete(id);
    }
    _exitSelectionMode();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final filtered = _listManager.filteredAndSorted;
    final showSmartCollections = _listManager.shouldShowSmartCollections(
      _searchCtrl.text,
      _listManager.getFilterCategoryId(),
    );

    // Get display title based on current filter
    final displayTitle = _getDisplayTitle(s);

    return Scaffold(
      appBar: _selectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              ),
              title: Text('${_selectedIds.length} selected'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _selectedIds.isNotEmpty ? _deleteSelected : null,
                ),
              ],
            )
          : AppBar(
        leading: _hasActiveFilter
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _clearFilter,
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: s.searchHint,
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : Text(displayTitle),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          if (!_isSearching) ...[
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              tooltip: _isGridView ? s.listView : s.gridView,
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
            PopupMenuButton<SortMode>(
              icon: const Icon(Icons.sort),
              tooltip: s.sort,
              onSelected: (mode) {
                _listManager.setSortMode(mode);
                setState(() {});
              },
              itemBuilder: (_) => [
                _listManager.buildSortMenuItem(context, SortMode.updatedDesc, s.sortUpdated),
                _listManager.buildSortMenuItem(context, SortMode.titleAsc, s.sortTitle),
                _listManager.buildSortMenuItem(context, SortMode.createdDesc, s.sortCreated),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'export') _handleExport();
                if (v == 'import') _handleImport();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'export', child: Text(s.exportLib)),
                PopupMenuItem(value: 'import', child: Text(s.importLib)),
              ],
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addBook',
        onPressed: _handleAddBook,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: filtered.isEmpty && _listManager.books.isEmpty
                ? BookListUi.buildEmptyState(
                    context: context,
                    hasSearchQuery: _searchCtrl.text.isNotEmpty,
                    onAddBook: _handleAddBook,
                  )
                : _buildContent(filtered, showSmartCollections),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final chips = _listManager.buildCategoryFilterChips(
      context,
      onChanged: () => setState(() {}),
    );
    if (chips.isEmpty) return const SizedBox.shrink();
    
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: chips,
      ),
    );
  }

  Widget _buildContent(List<Book> filtered, bool showSmartCollections) {
    if (filtered.isEmpty) {
      return BookListUi.buildEmptyState(
        context: context,
        hasSearchQuery: _searchCtrl.text.isNotEmpty,
        onAddBook: _handleAddBook,
      );
    }

    final recentBooks = _listManager.getRecentlyOpened(limit: 5);
    final showRecent = recentBooks.isNotEmpty &&
        _searchCtrl.text.isEmpty &&
        _listManager.getFilterCategoryId() == null;

    if (!showRecent) {
      return _isGridView
          ? BookListUi.buildResponsiveGridView(
              context: context,
              books: filtered,
              onTap: (book) => _selectionMode
                  ? _toggleSelection(book.id)
                  : (book.canRead ? _handleOpenBook(book) : _handleEditBook(book)),
              onEdit: _handleEditBook,
              onDelete: _handleConfirmDeleteBook,
              onExportAnnotations: _handleExportAnnotations,
              onLongPress: _selectionMode ? (book) => _toggleSelection(book.id) : (book) => _enterSelectionMode(book.id),
              selectedIds: _selectionMode ? _selectedIds : null,
            )
          : BookListUi.buildListView(
              books: filtered,
              onTap: (book) => _selectionMode
                  ? _toggleSelection(book.id)
                  : (book.canRead ? _handleOpenBook(book) : _handleEditBook(book)),
              onEdit: _handleEditBook,
              onDelete: _handleConfirmDeleteBook,
              onDismiss: (book) => _handleDeleteBook(context, book),
            );
    }

    // Show smart collections + continue reading + recently opened + all books
    final s = AppStrings.of(context);
    final collections = _listManager.getSmartCollections();
    
    return CustomScrollView(
      slivers: [
        // Continue reading card
        if (recentBooks.isNotEmpty)
          SliverToBoxAdapter(
            child: BookListUi.buildContinueReadingCard(
              context: context,
              book: recentBooks.first,
              onContinue: () => _handleOpenBook(recentBooks.first),
            ),
          ),
        // Smart collections
        if (showSmartCollections) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(s.smartCollections,
                  style: Theme.of(context).textTheme.titleSmall),
            ),
          ),
          SliverToBoxAdapter(
            child: BookListUi.buildSmartCollectionsList(
              context: context,
              collections: collections,
              onCollectionTap: _handleSmartCollectionTap,
            ),
          ),
        ],
        // Recently opened
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, showSmartCollections ? 12.0 : 8.0, 16, 4),
            child: Text(s.recentlyOpened,
                style: Theme.of(context).textTheme.titleSmall),
          ),
        ),
        SliverToBoxAdapter(
          child: BookListUi.buildRecentBooksList(
            recentBooks: recentBooks,
            onTap: _handleOpenBook,
          ),
        ),
        // All books
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(s.all,
                style: Theme.of(context).textTheme.titleSmall),
          ),
        ),
        if (_isGridView)
          BookListUi.buildResponsiveSliverGrid(
            context: context,
            books: filtered,
            onTap: (book) => _selectionMode
                ? _toggleSelection(book.id)
                : (book.canRead ? _handleOpenBook(book) : _handleEditBook(book)),
            onEdit: _handleEditBook,
            onDelete: _handleConfirmDeleteBook,
            onExportAnnotations: _handleExportAnnotations,
            onLongPress: _selectionMode ? (book) => _toggleSelection(book.id) : (book) => _enterSelectionMode(book.id),
            selectedIds: _selectionMode ? _selectedIds : null,
          )
        else
          BookListUi.buildSliverList(
            books: filtered,
            onTap: (book) => book.canRead ? _handleOpenBook(book) : _handleEditBook(book),
            onEdit: _handleEditBook,
            onDelete: _handleConfirmDeleteBook,
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }
}