import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../main.dart';

class BookCardLogic {
  final String bookId;
  final String? filePath;
  
  ui.Image? thumbnail;
  String? loadedBookId;
  bool isLoading = false;

  BookCardLogic({
    required this.bookId,
    required this.filePath,
  });

  void resetForNewBook(String newBookId, String? newFilePath) {
    if (loadedBookId == newBookId) return;
    loadedBookId = newBookId;
    thumbnail = null;
    isLoading = newFilePath != null;
  }

  Future<void> loadThumbnail({
    required BuildContext context,
    required String bookId,
    required String? filePath,
  }) async {
    if (filePath == null) return;
    final svc = ThumbnailServiceScope.of(context);
    final img = await svc.getThumbnail(
      bookId: bookId,
      filePath: filePath,
      width: 300,
    );
    thumbnail = img;
    isLoading = false;
  }

  Color? getCategoryColor({
    required BuildContext context,
    required String? categoryId,
  }) {
    if (categoryId == null) return null;
    final catService = CategoryServiceScope.of(context);
    final cat = catService.getById(categoryId);
    return cat != null ? Color(cat.colorValue) : null;
  }
}