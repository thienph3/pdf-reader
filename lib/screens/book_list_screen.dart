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
import 'book_list_selection.dart';
import 'book_list_content.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});
  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  bool _isSearching = false, _initialized = false, _isGridView = true;
  final TextEditingController _searchCtrl = TextEditingController();
  late BookListManager _listManager;
  late BookActionsManager _actionsManager;
  final BookListSelection _selection = BookListSelection();

  BookService get _bookService => BookServiceScope.of(context);
  CategoryService get _catService => CategoryServiceScope.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _listManager = BookListManager(bookService: _bookService, categoryService: _catService, searchController: _searchCtrl);
      _actionsManager = BookActionsManager(bookService: _bookService);
      _refresh();
    }
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _refresh() { _listManager.refresh(); setState(() {}); }

  Future<void> _handleDeleteBook(BuildContext context, Book book) async { await _listManager.deleteBook(context, book); _refresh(); }
  Future<void> _handleOpenBook(Book book) async { await _actionsManager.openBook(context, book, validateBookPath: validateBookPath, onRefresh: _refresh); }
  Future<void> _handleAddBook() async { await _actionsManager.addBook(context, onRefresh: _refresh); }
  Future<void> _handleEditBook(Book book) async { await _actionsManager.editBook(context, book, onRefresh: _refresh); }
  Future<void> _handleConfirmDeleteBook(Book book) async { await _actionsManager.confirmAndDeleteBook(context, book, onDelete: _handleDeleteBook); }
  Future<void> _handleExport() async { await _actionsManager.exportBooks(context, exportFunction: exportBooks); }
  Future<void> _handleImport() async { await _actionsManager.importBooks(context, importFunction: (ctx, bs) => importBooks(ctx, bs), onRefresh: _refresh); }

  Future<void> _handleExportAnnotations(Book book) async {
    final s = AppStrings.of(context);
    if (book.highlights.isEmpty && book.bookmarks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.noAnnotations)));
      return;
    }
    final md = exportAnnotationsAsMarkdown(book);
    final path = await FilePicker.saveFile(dialogTitle: s.exportAnnotations, fileName: '${book.title}_annotations.md');
    if (path == null) return;
    await io.File(path).writeAsString(md);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.exportAnnotationsSuccess)));
  }

  void _filterBySmartCollection(String title) {
    setState(() {
      _searchCtrl.text = '';
      _listManager.setFilterCategoryId(null);
      switch (title) {
        case 'Recently Added': _listManager.setSmartFilter(SmartFilter.recentlyAdded);
        case 'Unread': _listManager.setSmartFilter(SmartFilter.unread);
        case 'Almost Finished': _listManager.setSmartFilter(SmartFilter.almostFinished);
        case 'Frequently Read': _listManager.setSmartFilter(SmartFilter.frequentlyRead);
      }
    });
  }

  String _getDisplayTitle(AppStrings s) {
    switch (_listManager.smartFilter) {
      case SmartFilter.recentlyAdded: return s.recentlyAdded;
      case SmartFilter.unread: return s.unreadBooks;
      case SmartFilter.almostFinished: return s.almostFinished;
      case SmartFilter.frequentlyRead: return s.frequentlyRead;
      case SmartFilter.none: break;
    }
    final catId = _listManager.getFilterCategoryId();
    if (catId != null) { final cat = _catService.getById(catId); if (cat != null) return cat.name; }
    return s.library;
  }

  bool get _hasActiveFilter => _listManager.smartFilter != SmartFilter.none || _listManager.getFilterCategoryId() != null;
  void _clearFilter() { setState(() { _searchCtrl.clear(); _listManager.setFilterCategoryId(null); _listManager.setSmartFilter(SmartFilter.none); }); }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final filtered = _listManager.filteredAndSorted;
    final showSmart = _listManager.shouldShowSmartCollections(_searchCtrl.text, _listManager.getFilterCategoryId());

    return Scaffold(
      appBar: _selection.selectionMode
          ? _buildSelectionAppBar(s)
          : _buildNormalAppBar(s),
      floatingActionButton: FloatingActionButton(heroTag: 'addBook', onPressed: _handleAddBook, child: const Icon(Icons.add)),
      body: Column(children: [
        _buildCategoryFilter(),
        Expanded(
          child: filtered.isEmpty && _listManager.books.isEmpty
              ? BookListUi.buildEmptyState(context: context, hasSearchQuery: _searchCtrl.text.isNotEmpty, onAddBook: _handleAddBook)
              : BookListContent.build(
                  context: context, filtered: filtered, showSmartCollections: showSmart,
                  isGridView: _isGridView, selectionMode: _selection.selectionMode,
                  selectedIds: _selection.selectedIds, listManager: _listManager,
                  searchText: _searchCtrl.text,
                  onTap: (book) => _selection.selectionMode ? setState(() => _selection.toggle(book.id)) : (book.canRead ? _handleOpenBook(book) : _handleEditBook(book)),
                  onEdit: _handleEditBook, onDelete: _handleConfirmDeleteBook,
                  onExportAnnotations: _handleExportAnnotations,
                  onLongPress: (book) { setState(() => _selection.selectionMode ? _selection.toggle(book.id) : _selection.enter(book.id)); },
                  onOpen: _handleOpenBook, onAddBook: _handleAddBook,
                  onCollectionTap: (title, _) => _filterBySmartCollection(title),
                ),
        ),
      ]),
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(AppStrings s) {
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selection.exit())),
      title: Text('${_selection.selectedIds.length} selected'),
      actions: [IconButton(icon: const Icon(Icons.delete), onPressed: _selection.selectedIds.isNotEmpty ? () => _selection.deleteSelected(context, _bookService, _refresh).then((_) => setState(() {})) : null)],
    );
  }

  PreferredSizeWidget _buildNormalAppBar(AppStrings s) {
    return AppBar(
      leading: _hasActiveFilter ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _clearFilter) : null,
      title: _isSearching ? TextField(controller: _searchCtrl, autofocus: true, decoration: InputDecoration(hintText: s.searchHint, border: InputBorder.none), onChanged: (_) => setState(() {})) : Text(_getDisplayTitle(s)),
      actions: [
        IconButton(icon: Icon(_isSearching ? Icons.close : Icons.search), onPressed: () => setState(() { _isSearching = !_isSearching; if (!_isSearching) _searchCtrl.clear(); })),
        if (!_isSearching) ...[
          IconButton(icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view), tooltip: _isGridView ? s.listView : s.gridView, onPressed: () => setState(() => _isGridView = !_isGridView)),
          PopupMenuButton<SortMode>(icon: const Icon(Icons.sort), tooltip: s.sort, onSelected: (m) { _listManager.setSortMode(m); setState(() {}); }, itemBuilder: (_) => [_listManager.buildSortMenuItem(context, SortMode.updatedDesc, s.sortUpdated), _listManager.buildSortMenuItem(context, SortMode.titleAsc, s.sortTitle), _listManager.buildSortMenuItem(context, SortMode.createdDesc, s.sortCreated)]),
          PopupMenuButton<String>(icon: const Icon(Icons.more_vert), onSelected: (v) { if (v == 'export') _handleExport(); if (v == 'import') _handleImport(); }, itemBuilder: (_) => [PopupMenuItem(value: 'export', child: Text(s.exportLib)), PopupMenuItem(value: 'import', child: Text(s.importLib))]),
        ],
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final chips = _listManager.buildCategoryFilterChips(context, onChanged: () => setState(() {}));
    if (chips.isEmpty) return const SizedBox.shrink();
    return SizedBox(height: 48, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), children: chips));
  }
}
