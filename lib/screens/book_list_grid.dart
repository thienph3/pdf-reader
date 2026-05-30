import 'package:flutter/material.dart';
import '../models/book.dart';
import 'widgets/book_card.dart';
import 'widgets/book_list_tile.dart';

/// Grid and list view builders for book list.
class BookListGridBuilder {
  static Widget buildResponsiveGridView({
    required BuildContext context,
    required List<Book> books,
    required Function(Book) onTap,
    required Function(Book) onEdit,
    required Function(Book) onDelete,
    Function(Book)? onExportAnnotations,
    Function(Book)? onLongPress,
    Set<String>? selectedIds,
  }) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900 ? 4 : (width >= 600 ? 3 : 2);
    return GridView.builder(
      padding: const EdgeInsets.all(12).copyWith(bottom: 80),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, childAspectRatio: 0.58,
        crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(book: book, onTap: () => onTap(book), onEdit: () => onEdit(book), onDelete: () => onDelete(book), onExportAnnotations: onExportAnnotations != null ? () => onExportAnnotations(book) : null, onLongPress: onLongPress != null ? () => onLongPress(book) : null, selected: selectedIds?.contains(book.id) ?? false);
      },
    );
  }

  static Widget buildResponsiveSliverGrid({
    required BuildContext context,
    required List<Book> books,
    required Function(Book) onTap,
    required Function(Book) onEdit,
    required Function(Book) onDelete,
    Function(Book)? onExportAnnotations,
    Function(Book)? onLongPress,
    Set<String>? selectedIds,
  }) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900 ? 4 : (width >= 600 ? 3 : 2);
    return SliverPadding(
      padding: const EdgeInsets.all(12).copyWith(bottom: 80),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, childAspectRatio: 0.58,
          crossAxisSpacing: 12, mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate((_, i) {
          final book = books[i];
          return BookCard(book: book, onTap: () => onTap(book), onEdit: () => onEdit(book), onDelete: () => onDelete(book), onExportAnnotations: onExportAnnotations != null ? () => onExportAnnotations(book) : null, onLongPress: onLongPress != null ? () => onLongPress(book) : null, selected: selectedIds?.contains(book.id) ?? false);
        }, childCount: books.length),
      ),
    );
  }

  static Widget buildListView({
    required List<Book> books,
    required Function(Book) onTap,
    required Function(Book) onEdit,
    required Function(Book) onDelete,
    required Function(Book) onDismiss,
  }) {
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
            child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
          ),
          confirmDismiss: (_) async { onDismiss(book); return false; },
          child: BookListTile(book: book, onTap: () => onTap(book), onEdit: () => onEdit(book), onDelete: () => onDelete(book)),
        );
      },
    );
  }

  static Widget buildSliverList({
    required List<Book> books,
    required Function(Book) onTap,
    required Function(Book) onEdit,
    required Function(Book) onDelete,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((_, i) {
        final book = books[i];
        return BookListTile(book: book, onTap: () => onTap(book), onEdit: () => onEdit(book), onDelete: () => onDelete(book));
      }, childCount: books.length),
    );
  }
}
