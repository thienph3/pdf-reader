import 'package:flutter/material.dart';
import '../models/book.dart';
import '../l10n/app_strings.dart';
import 'book_list_manager.dart';
import 'book_list_ui.dart';

class BookListContent {
  static Widget build({
    required BuildContext context,
    required List<Book> filtered,
    required bool showSmartCollections,
    required bool isGridView,
    required bool selectionMode,
    required Set<String> selectedIds,
    required BookListManager listManager,
    required String searchText,
    required void Function(Book) onTap,
    required void Function(Book) onEdit,
    required void Function(Book) onDelete,
    required void Function(Book) onExportAnnotations,
    required void Function(Book) onLongPress,
    required void Function(Book) onOpen,
    required VoidCallback onAddBook,
    required void Function(String, int) onCollectionTap,
  }) {
    if (filtered.isEmpty) {
      return BookListUi.buildEmptyState(
        context: context,
        hasSearchQuery: searchText.isNotEmpty,
        onAddBook: onAddBook,
      );
    }

    final recentBooks = listManager.getRecentlyOpened(limit: 5);
    final showRecent = recentBooks.isNotEmpty &&
        searchText.isEmpty &&
        listManager.getFilterCategoryId() == null;

    if (!showRecent) {
      return isGridView
          ? BookListUi.buildResponsiveGridView(
              context: context, books: filtered, onTap: onTap,
              onEdit: onEdit, onDelete: onDelete,
              onExportAnnotations: onExportAnnotations,
              onLongPress: onLongPress,
              selectedIds: selectionMode ? selectedIds : null,
            )
          : BookListUi.buildListView(
              books: filtered, onTap: onTap, onEdit: onEdit,
              onDelete: onDelete, onDismiss: onDelete,
            );
    }

    final s = AppStrings.of(context);
    final collections = listManager.getSmartCollections();

    return CustomScrollView(
      slivers: [
        if (recentBooks.isNotEmpty)
          SliverToBoxAdapter(
            child: BookListUi.buildContinueReadingCard(
              context: context, book: recentBooks.first,
              onContinue: () => onOpen(recentBooks.first),
            ),
          ),
        if (showSmartCollections) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(s.smartCollections, style: Theme.of(context).textTheme.titleSmall),
            ),
          ),
          SliverToBoxAdapter(
            child: BookListUi.buildSmartCollectionsList(
              context: context, collections: collections,
              onCollectionTap: onCollectionTap,
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, showSmartCollections ? 12.0 : 8.0, 16, 4),
            child: Text(s.recentlyOpened, style: Theme.of(context).textTheme.titleSmall),
          ),
        ),
        SliverToBoxAdapter(
          child: BookListUi.buildRecentBooksList(recentBooks: recentBooks, onTap: onOpen),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(s.all, style: Theme.of(context).textTheme.titleSmall),
          ),
        ),
        if (isGridView)
          BookListUi.buildResponsiveSliverGrid(
            context: context, books: filtered, onTap: onTap,
            onEdit: onEdit, onDelete: onDelete,
            onExportAnnotations: onExportAnnotations,
            onLongPress: onLongPress,
            selectedIds: selectionMode ? selectedIds : null,
          )
        else
          BookListUi.buildSliverList(
            books: filtered, onTap: (book) => onOpen(book),
            onEdit: onEdit, onDelete: onDelete,
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }
}
