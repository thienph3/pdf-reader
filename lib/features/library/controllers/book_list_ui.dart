import 'package:flutter/material.dart';
import '../../../models/book.dart';
import '../../../core/l10n/app_strings.dart';
import '../widgets/recent_book_item.dart';
import './book_list_grid.dart';

/// UI components for the book list screen.
class BookListUi {
  static Widget buildContinueReadingCard({
    required BuildContext context, required Book book, required VoidCallback onContinue,
  }) {
    final s = AppStrings.of(context);
    final percent = (book.progressPercent * 100).toInt();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.auto_stories),
          title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${s.progress(percent)} ${s.continueReading.toLowerCase()}'),
          trailing: FilledButton(onPressed: onContinue, child: Text(s.continueBtn)),
        ),
      ),
    );
  }

  static Widget buildResponsiveGridView({
    required BuildContext context, required List<Book> books,
    required Function(Book) onTap, required Function(Book) onEdit,
    required Function(Book) onDelete, Function(Book)? onExportAnnotations,
    Function(Book)? onLongPress, Set<String>? selectedIds,
  }) => BookListGridBuilder.buildResponsiveGridView(context: context, books: books, onTap: onTap, onEdit: onEdit, onDelete: onDelete, onExportAnnotations: onExportAnnotations, onLongPress: onLongPress, selectedIds: selectedIds);

  static Widget buildResponsiveSliverGrid({
    required BuildContext context, required List<Book> books,
    required Function(Book) onTap, required Function(Book) onEdit,
    required Function(Book) onDelete, Function(Book)? onExportAnnotations,
    Function(Book)? onLongPress, Set<String>? selectedIds,
  }) => BookListGridBuilder.buildResponsiveSliverGrid(context: context, books: books, onTap: onTap, onEdit: onEdit, onDelete: onDelete, onExportAnnotations: onExportAnnotations, onLongPress: onLongPress, selectedIds: selectedIds);

  static Widget buildListView({
    required List<Book> books, required Function(Book) onTap,
    required Function(Book) onEdit, required Function(Book) onDelete,
    required Function(Book) onDismiss,
  }) => BookListGridBuilder.buildListView(books: books, onTap: onTap, onEdit: onEdit, onDelete: onDelete, onDismiss: onDismiss);

  static Widget buildSliverList({
    required List<Book> books, required Function(Book) onTap,
    required Function(Book) onEdit, required Function(Book) onDelete,
  }) => BookListGridBuilder.buildSliverList(books: books, onTap: onTap, onEdit: onEdit, onDelete: onDelete);

  static Widget buildEmptyState({
    required BuildContext context, required bool hasSearchQuery, required VoidCallback onAddBook,
  }) {
    final s = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(hasSearchQuery ? Icons.search_off : Icons.auto_stories_outlined, size: 80, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 24),
          Text(hasSearchQuery ? s.noResults : s.noBooks, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          if (!hasSearchQuery) ...[
            const SizedBox(height: 8),
            Text(s.addBookHint, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(onPressed: onAddBook, icon: const Icon(Icons.add), label: Text(s.addBook)),
          ],
        ]),
      ),
    );
  }

  static Widget buildSmartCollectionCard({
    required BuildContext context, required String title, required int bookCount,
    required IconData icon, required Color color, required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 160, padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: 20)),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(AppStrings.of(context).nBooks(bookCount), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          ),
        ),
      ),
    );
  }

  static Widget buildRecentBooksList({required List<Book> recentBooks, required Function(Book) onTap}) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: recentBooks.length,
        itemBuilder: (_, i) {
          final book = recentBooks[i];
          return Padding(padding: const EdgeInsets.only(right: 10), child: RecentBookItem(book: book, onTap: () => onTap(book)));
        },
      ),
    );
  }

  static Widget buildSmartCollectionsList({
    required BuildContext context, required List<dynamic> collections,
    required Function(String, int) onCollectionTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [colorScheme.primary, colorScheme.secondary, colorScheme.tertiary, colorScheme.error];
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: collections.asMap().entries.map((entry) {
          final color = entry.key < colors.length ? colors[entry.key] : colorScheme.primary;
          final c = entry.value;
          return buildSmartCollectionCard(context: context, title: c.title, bookCount: c.count, icon: c.icon, color: color, onTap: () => onCollectionTap(c.title, c.count));
        }).toList(),
      ),
    );
  }
}
