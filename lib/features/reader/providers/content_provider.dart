import 'package:flutter/material.dart';

/// Abstract interface for content rendering, decoupling format from UI.
abstract class ContentProvider {
  /// Total pages/chapters in the document.
  int get totalPages;

  /// Whether the content is still loading.
  bool get isLoading;

  /// Error message if loading failed.
  String? get error;

  /// Get text content for a page (for TTS).
  Future<String?> getTextForPage(int page);

  /// Build the content widget for display.
  Widget buildContent(BuildContext context, {
    required int currentPage,
    required ValueChanged<int> onPageChanged,
    required VoidCallback onReady,
    PageController? pageController,
  });

  /// Dispose resources.
  void dispose();
}
