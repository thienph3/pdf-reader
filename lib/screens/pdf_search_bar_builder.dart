import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../l10n/app_strings.dart';

PreferredSizeWidget buildPdfSearchBar({
  required BuildContext context,
  required TextEditingController searchController,
  required PdfTextSearcher? textSearcher,
  required VoidCallback onBackPressed,
  required ValueChanged<String> onSearchSubmitted,
}) {
  final s = AppStrings.of(context);
  return AppBar(
    leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBackPressed),
    title: TextField(
      controller: searchController, autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(hintText: s.searchHintPdf, border: InputBorder.none),
      onSubmitted: onSearchSubmitted,
    ),
    actions: [
      if (textSearcher != null)
        ListenableBuilder(
          listenable: textSearcher,
          builder: (context, child) {
            final matches = textSearcher.matches;
            final currentIdx = textSearcher.currentIndex;
            final hasMatches = matches.isNotEmpty && currentIdx != null;
            final isFirst = !hasMatches || currentIdx <= 0;
            final isLast = !hasMatches || currentIdx >= matches.length - 1;
            return Row(mainAxisSize: MainAxisSize.min, children: [
              if (hasMatches) Padding(padding: const EdgeInsets.only(right: 4), child: Text('${currentIdx + 1}/${matches.length}', style: Theme.of(context).textTheme.bodySmall)),
              IconButton(icon: const Icon(Icons.navigate_before), onPressed: hasMatches && !isFirst ? () => textSearcher.goToPrevMatch() : null),
              IconButton(icon: const Icon(Icons.navigate_next), onPressed: hasMatches && !isLast ? () => textSearcher.goToNextMatch() : null),
            ]);
          },
        ),
    ],
  );
}
