import 'package:flutter/material.dart';
import '../models/book.dart';
import '../l10n/app_strings.dart';
import 'widgets/book_card.dart';
import 'widgets/book_list_tile.dart';
import 'widgets/recent_book_item.dart';

/// UI components for the book list screen.
class BookListUi {
  /// Builds an empty state widget.
  static Widget buildEmptyState({
    required BuildContext context,
    required bool hasSearchQuery,
    required VoidCallback onAddBook,
  }) {
    final s = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearchQuery ? Icons.search_off : Icons.auto_stories_outlined,
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              hasSearchQuery ? s.noResults : s.noBooks,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (!hasSearchQuery) ...[
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
                onPressed: onAddBook,
                icon: const Icon(Icons.add),
                label: Text(s.addBook),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a smart collection card.
  static Widget buildSmartCollectionCard({
    required BuildContext context,
    required String title,
    required int bookCount,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$bookCount books',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a grid view of books.
  static Widget buildGridView({
    required List<Book> books,
    required Function(Book) onTap,
    required Function(Book) onEdit,
    required Function(Book) onDelete,
  }) {
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
          onTap: () => onTap(book),
          onEdit: () => onEdit(book),
          onDelete: () => onDelete(book),
        );
      },
    );
  }

  /// Builds a list view of books with dismissible items.
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
            child: Icon(Icons.delete,
                color: Theme.of(context).colorScheme.onError),
          ),
          confirmDismiss: (_) async {
            onDismiss(book);
            return false;
          },
          child: BookListTile(
            book: book,
            onTap: () => onTap(book),
            onEdit: () => onEdit(book),
            onDelete: () => onDelete(book),
          ),
        );
      },
    );
  }

  /// Builds a sliver grid for books.
  static Widget buildSliverGrid({
    required List<Book> books,
    required Function(Book) onTap,
    required Function(Book) onEdit,
    required Function(Book) onDelete,
  }) {
    return SliverPadding(
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
            final book = books[i];
            return BookCard(
              book: book,
              onTap: () => onTap(book),
              onEdit: () => onEdit(book),
              onDelete: () => onDelete(book),
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }

  /// Builds a sliver list for books.
  static Widget buildSliverList({
    required List<Book> books,
    required Function(Book) onTap,
    required Function(Book) onEdit,
    required Function(Book) onDelete,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) {
          final book = books[i];
          return BookListTile(
            book: book,
            onTap: () => onTap(book),
            onEdit: () => onEdit(book),
            onDelete: () => onDelete(book),
          );
        },
        childCount: books.length,
      ),
    );
  }

  /// Builds a horizontal list of recent books.
  static Widget buildRecentBooksList({
    required List<Book> recentBooks,
    required Function(Book) onTap,
  }) {
    return SizedBox(
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
              onTap: () => onTap(book),
            ),
          );
        },
      ),
    );
  }

  /// Builds a horizontal list of smart collection cards.
  static Widget buildSmartCollectionsList({
    required BuildContext context,
    required List<dynamic> collections,
    required Function(String, int) onCollectionTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
    ];

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: collections.asMap().entries.map((entry) {
          final index = entry.key;
          final collection = entry.value;
          final color = index < colors.length ? colors[index] : colorScheme.primary;
          
          return buildSmartCollectionCard(
            context: context,
            title: collection.title,
            bookCount: collection.count,
            icon: collection.icon,
            color: color,
            onTap: () => onCollectionTap(collection.title, collection.count),
          );
        }).toList(),
      ),
    );
  }
}