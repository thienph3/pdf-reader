import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Search results count bar at bottom of viewer.
class SearchResultsBar extends StatelessWidget {
  final PdfTextSearcher textSearcher;
  const SearchResultsBar({super.key, required this.textSearcher});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: textSearcher,
      builder: (context, child) {
        final count = textSearcher.matches.length;
        if (count == 0 && !textSearcher.isSearching) {
          return const SizedBox.shrink();
        }
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: colorScheme.surfaceContainerHighest,
          child: textSearcher.isSearching
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Searching...'),
                  ],
                )
              : Text(
                  '$count ${count == 1 ? 'result' : 'results'}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
        );
      },
    );
  }
}
