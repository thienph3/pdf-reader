import 'package:flutter/material.dart';
import '../../features/reader/screens/reader_screen.dart';

/// Shared page transition for all navigation in the app.
Route<T> buildPageRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      );
    },
  );
}

/// Opens the reader with standard parameters (PDF or EPUB).
Future<void> openPdfViewer(
  BuildContext context, {
  required String filePath,
  required String fileName,
  String? bookId,
  int initialPage = 0,
}) {
  return Navigator.push(context, buildPageRoute(ReaderScreen(
    filePath: filePath,
    fileName: fileName,
    bookId: bookId,
    initialPage: initialPage,
  )));
}
