import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epub_plus/epub_plus.dart';
import '../../../app/main.dart';
import '../../../core/l10n/app_strings.dart';

String _stripHtml(String html) =>
    html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

class EpubViewScreen extends StatefulWidget {
  final String filePath;
  final String fileName;
  final String? bookId;

  const EpubViewScreen({
    super.key,
    required this.filePath,
    required this.fileName,
    this.bookId,
  });

  @override
  State<EpubViewScreen> createState() => _EpubViewScreenState();
}

class _EpubViewScreenState extends State<EpubViewScreen> {
  late final PageController _pageController;
  List<EpubChapter> _chapters = [];
  bool _loading = true;
  String? _error;
  int _currentChapter = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadEpub();
  }

  Future<void> _loadEpub() async {
    try {
      final bytes = await File(widget.filePath).readAsBytes();
      final book = await EpubReader.readBook(bytes);
      final chapters = book.chapters.where((c) => c.htmlContent != null && c.htmlContent!.isNotEmpty).toList();
      if (!mounted) return;

      // Restore progress
      int startChapter = 0;
      if (widget.bookId != null) {
        final bookService = BookServiceScope.of(context);
        final saved = bookService.getById(widget.bookId!);
        if (saved != null && saved.lastPage < chapters.length) {
          startChapter = saved.lastPage;
        }
      }

      setState(() {
        _chapters = chapters;
        _currentChapter = startChapter;
        _loading = false;
      });
      if (startChapter > 0) {
        _pageController.jumpToPage(startChapter);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentChapter = index);
    _saveProgress(index);
  }

  void _saveProgress(int chapter) {
    if (widget.bookId == null) return;
    final bookService = BookServiceScope.of(context);
    final book = bookService.getById(widget.bookId!);
    if (book == null) return;
    bookService.update(book.copyWith(
      lastPage: chapter,
      totalPages: _chapters.length,
      lastOpenedAt: () => DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.fileName)),
        body: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(s.epubLoading),
          ],
        )),
      );
    }

    if (_error != null || _chapters.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.fileName)),
        body: Center(child: Text(_error ?? s.epubError)),
      );
    }

    final chapter = _chapters[_currentChapter];
    final title = chapter.title ?? '${s.epubChapter} ${_currentChapter + 1}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Center(child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text('${_currentChapter + 1}/${_chapters.length}'),
          )),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _chapters.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final text = _stripHtml(_chapters[index].htmlContent ?? '');
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              text,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          );
        },
      ),
    );
  }
}
