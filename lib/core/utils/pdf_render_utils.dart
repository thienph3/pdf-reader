import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:pdfrx/pdfrx.dart';

/// Renders a PDF page to PNG bytes. Used by OCR and thumbnail services.
Future<Uint8List?> renderPageToPngBytes(
  PdfPage page, {
  double width = 1000,
  double height = 1400,
}) async {
  final rendered = await page.render(fullWidth: width, fullHeight: height);
  if (rendered == null) return null;
  final uiImage = await rendered.createImage();
  try {
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } finally {
    uiImage.dispose();
  }
}
