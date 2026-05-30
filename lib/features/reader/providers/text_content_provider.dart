import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'content_provider.dart';

/// Plain text / Markdown implementation of [ContentProvider].
/// Splits content into pages by character count for readability.
class TextContentProvider extends ContentProvider {
  final String filePath;
  static const _charsPerPage = 2000;

  List<String> _pages = [];
  String _fullText = '';
  bool _loading = true;
  bool _isMarkdown = false;
  String? _error;

  @override
  int get totalPages => _pages.length;
  @override
  bool get isLoading => _loading;
  @override
  String? get error => _error;

  TextContentProvider({required this.filePath});

  Future<void> load() async {
    try {
      _fullText = await File(filePath).readAsString();
      _isMarkdown = filePath.endsWith('.md');
      // Split into pages by paragraph boundaries near _charsPerPage
      _pages = _splitIntoPages(_fullText);
      _loading = false;
    } catch (e) {
      _error = e.toString();
      _loading = false;
    }
  }

  List<String> _splitIntoPages(String text) {
    if (text.length <= _charsPerPage) return [text];
    final pages = <String>[];
    var start = 0;
    while (start < text.length) {
      var end = start + _charsPerPage;
      if (end >= text.length) {
        pages.add(text.substring(start));
        break;
      }
      // Find nearest paragraph break
      final newline = text.lastIndexOf('\n\n', end);
      if (newline > start) end = newline + 2;
      pages.add(text.substring(start, end));
      start = end;
    }
    return pages;
  }

  @override
  Future<String?> getTextForPage(int page) async {
    if (page < 0 || page >= _pages.length) return null;
    return _pages[page];
  }

  @override
  Widget buildContent(BuildContext context, {
    required int currentPage,
    required ValueChanged<int> onPageChanged,
    required VoidCallback onReady,
    PageController? pageController,
  }) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
    return PageView.builder(
      controller: pageController,
      itemCount: _pages.length,
      onPageChanged: onPageChanged,
      itemBuilder: (_, index) {
        final content = _pages[index];
        if (_isMarkdown) {
          return Markdown(data: content, selectable: true, padding: const EdgeInsets.all(16));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(content, style: const TextStyle(fontSize: 16, height: 1.6)),
        );
      },
    );
  }

  @override
  void dispose() {}
}
