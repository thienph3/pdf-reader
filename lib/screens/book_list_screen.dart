import 'package:flutter/material.dart';
import '../main.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/category_service.dart';
import '../l10n/app_strings.dart';
import 'shared_route.dart';
import 'book_actions.dart';
import 'book_form_screen.dart';
import 'pdf_view_screen.dart';
import 'widgets/book_card.dart';
import 'widgets/book_list_tile.dart';
import 'widgets/recent_book_item.dart';

enum SortMode { updatedDesc, titleAsc, createdDesc }

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<Book> _books = [];
  bool _isSearching = false;
  bool _initialized = false;
  bool _isGridView = true;
  SortMode _sortMode = SortMode.updatedDesc;
  String? _filterCategoryId;

  final TextEditingController _searchCtrl = TextEditingController();

  BookService get _bookService => BookServiceScope.of(context);
  CategoryService get _catService => CategoryServiceScope.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _refresh();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => _books = _bookService.getAll());

  List<Book> get _filteredAndSorted {
    var result = _books;
    if (_filterCategoryId != null) {
      result = result.where((b) => b.categoryId == _filterCategoryId).toList();
    }
    final q = _searchCtrl.text.toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where((b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q))
          .toList();
    }
    switch (_sortMode) {
      case SortMode.updatedDesc:
        break;
      case SortMode.titleAsc:
        result = List.of(result)
          ..sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SortMode.createdDesc:
        result = List.of(result)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  Future<void> _addBook() async {
    final created = await Navigator.push<bool>(
        context, buildPageRoute(const BookFormScreen()));
    if (created == true) _refresh();
  }

  Future<void> _editBook(Book book) async {
    final updated = await Navigator.push<bool>(
        context, buildPageRoute(BookFormScreen(book: book)));
    if (updated == true) _refresh();
  }

  Future<void> _deleteBook(Book book) async {
    final s = AppStrings.of(context);
    await _bookService.delete(book.id);
    _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.bookDeleted(book.title)),
        action: SnackBarAction(
          label: s.undo,
          onPressed: () async {
            await _bookService.restore(book);
            _refresh();
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteBook(Book book) async {
    final s = AppStrings.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteBook),
        content: Text(s.deleteBookConfirm(book.title)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.delete)),
        ],
      ),
    );
    if (confirm == true) _deleteBook(book);
  }

  Future<void> _openBook(Book book) async {
    if (!book.canRead) return;
    final file = await validateBookPath(context, book, _bookService);
    if (file != null) _refresh(); // path may have been updated
    if (file == null || !mounted) return;
    await Navigator.push(
      context,
      buildPageRoute(PdfViewScreen(
        filePath: file,
        fileName: book.title,
        bookId: book.id,
        initialPage: book.lastPage,
      )),
    );
    _refresh();
  }

  Future<void> _doExport() async {
    await exportBooks(context, _bookService);
  }

  Future<void> _doImport() async {
    final count = await importBooks(context, _bookService);
    if (count > 0) _refresh();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final filtered = _filteredAndSorted;

    return Scaffold(
      appBar: AppBar(
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
            : Text(s.library),
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
              onSelected: (mode) => setState(() => _sortMode = mode),
              itemBuilder: (_) => [
                _sortMenuItem(SortMode.updatedDesc, s.sortUpdated),
                _sortMenuItem(SortMode.titleAsc, s.sortTitle),
                _sortMenuItem(SortMode.createdDesc, s.sortCreated),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'export') _doExport();
                if (v == 'import') _doImport();
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
        onPressed: _addBook,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: filtered.isEmpty && _books.isEmpty
                ? _buildEmptyState()
                : _buildContent(filtered),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<SortMode> _sortMenuItem(SortMode mode, String label) {
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

  Widget _buildCategoryFilter() {
    final s = AppStrings.of(context);
    final categories = _catService.getAll();
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(s.all),
              selected: _filterCategoryId == null,
              onSelected: (_) => setState(() => _filterCategoryId = null),
            ),
          ),
          ...categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: CircleAvatar(
                    radius: 6,
                    backgroundColor: Color(cat.colorValue),
                  ),
                  label: Text(cat.name),
                  selected: _filterCategoryId == cat.id,
                  onSelected: (_) => setState(
                    () => _filterCategoryId =
                        _filterCategoryId == cat.id ? null : cat.id,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildContent(List<Book> filtered) {
    if (filtered.isEmpty) return _buildEmptyState();

    final recentBooks = _bookService.getRecentlyOpened(limit: 5);
    final showRecent = recentBooks.isNotEmpty &&
        _searchCtrl.text.isEmpty &&
        _filterCategoryId == null;

    if (!showRecent) {
      return _isGridView ? _buildGrid(filtered) : _buildList(filtered);
    }

    // Show recently opened + all books
    final s = AppStrings.of(context);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(s.recentlyOpened,
                style: Theme.of(context).textTheme.titleSmall),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: recentBooks.length,
              itemBuilder: (_, i) {
                final book = recentBooks[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: RecentBookItem(
                    book: book,
                    onTap: () => _openBook(book),
                  ),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(s.all,
                style: Theme.of(context).textTheme.titleSmall),
          ),
        ),
        if (_isGridView)
          SliverPadding(
            padding: const EdgeInsets.all(12).copyWith(bottom: 80),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final book = filtered[i];
                  return BookCard(
                    book: book,
                    onTap: () =>
                        book.canRead ? _openBook(book) : _editBook(book),
                    onEdit: () => _editBook(book),
                    onDelete: () => _confirmDeleteBook(book),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final book = filtered[i];
                return BookListTile(
                  book: book,
                  onTap: () =>
                      book.canRead ? _openBook(book) : _editBook(book),
                  onEdit: () => _editBook(book),
                  onDelete: () => _confirmDeleteBook(book),
                );
              },
              childCount: filtered.length,
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Widget _buildEmptyState() {
    final s = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final hasQuery = _searchCtrl.text.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_off : Icons.auto_stories_outlined,
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              hasQuery ? s.noResults : s.noBooks,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (!hasQuery) ...[
              const SizedBox(height: 8),
              Text(
                s.addBookHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _addBook,
                icon: const Icon(Icons.add),
                label: Text(s.addBook),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Book> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(12).copyWith(bottom: 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          book: book,
          onTap: () => book.canRead ? _openBook(book) : _editBook(book),
          onEdit: () => _editBook(book),
          onDelete: () => _confirmDeleteBook(book),
        );
      },
    );
  }

  Widget _buildList(List<Book> books) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Dismissible(
          key: ValueKey(book.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: Theme.of(context).colorScheme.error,
            child: Icon(Icons.delete,
                color: Theme.of(context).colorScheme.onError),
          ),
          confirmDismiss: (_) async {
            _deleteBook(book);
            return false;
          },
          child: BookListTile(
            book: book,
            onTap: () => book.canRead ? _openBook(book) : _editBook(book),
            onEdit: () => _editBook(book),
            onDelete: () => _confirmDeleteBook(book),
          ),
        );
      },
    );
  }
}
