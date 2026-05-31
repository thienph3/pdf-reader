import 'package:flutter/material.dart';
import '../../../app/main.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../models/book.dart';
import '../../reader/screens/reader_screen.dart';

class CrossBookSearchScreen extends StatefulWidget {
  const CrossBookSearchScreen({super.key});
  @override
  State<CrossBookSearchScreen> createState() => _CrossBookSearchScreenState();
}

class _CrossBookSearchScreenState extends State<CrossBookSearchScreen> {
  final _ctrl = TextEditingController();
  List<_SearchResult> _results = [];

  void _search(String query) {
    if (query.trim().isEmpty) { setState(() => _results = []); return; }
    final q = query.toLowerCase();
    final bookService = BookServiceScope.of(context);
    final results = <_SearchResult>[];
    for (final book in bookService.getAll()) {
      if (book.title.toLowerCase().contains(q)) {
        results.add(_SearchResult(book: book, page: book.lastPage, text: book.title, type: 'title'));
      }
      for (final h in book.highlights) {
        if (h.text.toLowerCase().contains(q) || h.note.toLowerCase().contains(q)) {
          results.add(_SearchResult(book: book, page: h.page, text: h.text, type: 'highlight'));
        }
      }
      for (final b in book.bookmarks) {
        if (b.note.toLowerCase().contains(q)) {
          results.add(_SearchResult(book: book, page: b.page, text: b.note, type: 'bookmark'));
        }
      }
    }
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: TextField(
        controller: _ctrl, autofocus: true,
        decoration: InputDecoration(hintText: s.searchHint, border: InputBorder.none),
        onSubmitted: _search, onChanged: _search,
      )),
      body: _results.isEmpty
          ? Center(child: Text(s.noResults))
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (ctx, i) {
                final r = _results[i];
                return ListTile(
                  title: Text(r.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${r.book.title} · ${s.page(r.page + 1)}'),
                  leading: Icon(r.type == 'highlight' ? Icons.highlight : r.type == 'bookmark' ? Icons.bookmark : Icons.book),
                  onTap: () {
                    if (!r.book.canRead) return;
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ReaderScreen(
                      filePath: r.book.filePath!, fileName: r.book.title,
                      bookId: r.book.id, initialPage: r.page,
                    )));
                  },
                );
              },
            ),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}

class _SearchResult {
  final Book book;
  final int page;
  final String text;
  final String type;
  const _SearchResult({required this.book, required this.page, required this.text, required this.type});
}
