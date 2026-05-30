import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

ColorFilter getReadingModeFilter(int readingMode) {
  switch (readingMode) {
    case 1: // sepia
      return const ColorFilter.matrix([
        0.94, 0.0, 0.0, 0.0, 30.0,
        0.0, 0.89, 0.0, 0.0, 15.0,
        0.0, 0.0, 0.79, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ]);
    case 2: // dark (invert + hue rotate)
      return const ColorFilter.matrix([
        -1.0, 0.0, 0.0, 0.0, 255.0,
        0.0, -1.0, 0.0, 0.0, 255.0,
        0.0, 0.0, -1.0, 0.0, 255.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ]);
    default:
      return const ColorFilter.mode(Colors.transparent, BlendMode.dst);
  }
}

PdfPageLayout horizontalLayout(List<PdfPage> pages, PdfViewerParams params) {
  final margin = params.margin;
  final height = pages.fold<double>(
          0.0, (prev, page) => prev > page.height ? prev : page.height) +
      margin * 2;
  final pageLayouts = <Rect>[];
  double x = margin;
  for (final page in pages) {
    pageLayouts.add(Rect.fromLTWH(
      x,
      (height - page.height) / 2,
      page.width,
      page.height,
    ));
    x += page.width + margin;
  }
  return PdfPageLayout(
      pageLayouts: pageLayouts, documentSize: Size(x, height));
}
