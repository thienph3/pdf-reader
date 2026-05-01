import 'package:flutter/material.dart';
import '../../models/highlight.dart';
import '../../l10n/app_strings.dart';

/// Highlights list bottom sheet.
class HighlightSheet extends StatelessWidget {
  final List<Highlight> highlights;
  final int currentPage;
  final ScrollController scrollController;
  final void Function(Highlight) onTap;
  final void Function(Highlight) onDelete;
  final void Function(Highlight) onEditNote;

  const HighlightSheet({
    super.key,
    required this.highlights,
    required this.currentPage,
    required this.scrollController,
    required this.onTap,
    required this.onDelete,
    required this.onEditNote,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final sorted = List.of(highlights)
      ..sort((a, b) => a.page != b.page
          ? a.page.compareTo(b.page)
          : a.startIndex.compareTo(b.startIndex));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(s.highlights,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: sorted.length,
            itemBuilder: (_, i) {
              final h = sorted[i];
              return ListTile(
                leading: Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(h.colorValue),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                title: Text(
                  '"${h.text}"',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  '${s.page(h.page + 1)}${h.note.isNotEmpty ? ' · ${h.note}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, size: 20),
                      onPressed: () => onEditNote(h),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => onDelete(h),
                    ),
                  ],
                ),
                onTap: () => onTap(h),
              );
            },
          ),
        ),
      ],
    );
  }
}
