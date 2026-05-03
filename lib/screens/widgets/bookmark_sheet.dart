import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../l10n/app_strings.dart';

/// Bookmark list with delete.
class BookmarkSheet extends StatelessWidget {
  final List<Bookmark> bookmarks;
  final int currentPage;
  final ScrollController scrollController;
  final void Function(int page) onTap;
  final void Function(int page) onDelete;

  const BookmarkSheet({
    super.key,
    required this.bookmarks,
    required this.currentPage,
    required this.scrollController,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final sorted = List.of(bookmarks)
      ..sort((a, b) => a.page.compareTo(b.page));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(s.bookmarkList,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: sorted.length,
            itemBuilder: (_, i) {
              final bm = sorted[i];
              final isCurrent = bm.page == currentPage;
              return ListTile(
                leading: Icon(
                  Icons.bookmark,
                  color: isCurrent
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(s.page(bm.page + 1)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => onDelete(bm.page),
                ),
                onTap: () => onTap(bm.page),
              );
            },
          ),
        ),
      ],
    );
  }
}
