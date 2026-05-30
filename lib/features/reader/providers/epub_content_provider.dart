import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epub_plus/epub_plus.dart';
import 'content_provider.dart';

String _stripHtml(String html) =>
    html.replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ').trim();

/// EPUB implementation of [ContentProvider].
class EpubContentProvider extends ContentProvider {
  final String filePath;
  List<EpubChapter> _chapters = [];
  bool _loading = true;
  String? _error;

  @override
  int get totalPages => _chapters.length;
  @override
  bool get isLoading => _loading;
  @override
  String? get error => _error;

  EpubContentProvider({required this.filePath});

  List<EpubChapter> get chapters => _chapters;

  String? getChapterTitle(int index) {
    if (index < 0 || index >= _chapters.length) return null;
    return _chapters[index].title;
  }

  Future<void> load() async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final book = await EpubReader.readBook(bytes);
      _chapters = book.chapters
          .where((c) => c.htmlContent != null && c.htmlContent!.isNotEmpty)
          .toList();
      _loading = false;
    } catch (e) {
      _error = e.toString();
      _loading = false;
    }
  }

  @override
  Future<String?> getTextForPage(int page) async {
    if (page < 0 || page >= _chapters.length) return null;
    return _stripHtml(_chapters[page].htmlContent ?? '');
  }

  @override
  Widget buildContent(BuildContext context, {
    required int currentPage,
    required ValueChanged<int> onPageChanged,
    required VoidCallback onReady,
    PageController? pageController,
  }) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _chapters.isEmpty) {
      return Center(child: Text(_error ?? 'No content'));
    }
    return PageView.builder(
      controller: pageController,
      itemCount: _chapters.length,
      onPageChanged: onPageChanged,
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
    );
  }

  @override
  void dispose() {}
}
