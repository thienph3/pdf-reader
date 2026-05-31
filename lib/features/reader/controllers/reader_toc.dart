part of 'reader_dialogs.dart';

/// Table of contents bottom sheet for PDF viewer.
extension _ReaderToc on PdfViewDialogsManager {
  void showToc(BuildContext context) async {
    final s = AppStrings.of(context);
    if (pdfDocument == null) return;
    final outline = await pdfDocument!.loadOutline();
    if (!context.mounted) return;
    if (outline.isEmpty) {
      showAppSnackBar(context, s.noToc);
      return;
    }
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(s.tableOfContents,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: outline.length,
                itemBuilder: (_, i) {
                  final item = outline[i];
                  return ListTile(
                    contentPadding: EdgeInsets.only(
                        left: 16.0 + (item.children.isNotEmpty ? 0 : 16)),
                    title: Text(item.title),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (item.dest != null) {
                        viewerController.goToDest(item.dest);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
