import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// OCR service for scanned PDF pages.
/// Results cached in Hive: plain text + markdown.
class OcrService extends ChangeNotifier {
  late Box<String> _textBox;
  late Box<String> _mdBox;
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  bool _isProcessing = false;
  int _currentPage = -1;

  bool get isProcessing => _isProcessing;
  int get currentPage => _currentPage;

  Future<void> init() async {
    _textBox = await Hive.openBox<String>('ocr_text');
    _mdBox = await Hive.openBox<String>('ocr_md');
  }

  String _key(String bookId, int page) => '${bookId}_$page';

  /// Get cached plain text.
  String? getCachedText(String bookId, int pageNumber) =>
      _textBox.get(_key(bookId, pageNumber));

  /// Get cached markdown.
  String? getCachedMarkdown(String bookId, int pageNumber) =>
      _mdBox.get(_key(bookId, pageNumber));

  bool hasOcrText(String bookId, int pageNumber) =>
      _textBox.containsKey(_key(bookId, pageNumber));

  /// OCR a page from PNG bytes. Returns plain text.
  Future<String> ocrFromPngBytes({
    required String bookId,
    required int pageNumber,
    required Uint8List pngBytes,
  }) async {
    final cached = getCachedText(bookId, pageNumber);
    if (cached != null) return cached;

    _isProcessing = true;
    _currentPage = pageNumber;
    notifyListeners();

    try {
      // Write PNG to temp file (ML Kit needs file path for PNG)
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/ocr_page_$pageNumber.png');
      await tempFile.writeAsBytes(pngBytes);

      final inputImage = InputImage.fromFilePath(tempFile.path);
      final result = await _recognizer.processImage(inputImage);
      final plainText = result.text;
      final markdown = _toMarkdown(result);

      final key = _key(bookId, pageNumber);
      await _textBox.put(key, plainText);
      await _mdBox.put(key, markdown);

      // Clean up temp file
      try { await tempFile.delete(); } catch (_) {}

      return plainText;
    } catch (e) {
      debugPrint('OCR error page $pageNumber: $e');
      return '';
    } finally {
      _isProcessing = false;
      _currentPage = -1;
      notifyListeners();
    }
  }

  /// Convert ML Kit RecognizedText to basic markdown.
  String _toMarkdown(RecognizedText result) {
    if (result.blocks.isEmpty) return '';

    final buf = StringBuffer();
    double? prevBlockBottom;

    for (final block in result.blocks) {
      // Detect heading: block with few lines + larger bounding box height per line
      final isHeading = _isLikelyHeading(block, result.blocks);

      // Paragraph gap: if vertical distance from previous block is large
      if (prevBlockBottom != null) {
        final gap = block.boundingBox.top - prevBlockBottom;
        if (gap > 20) {
          buf.write('\n\n');
        }
      }

      if (isHeading) {
        buf.write('## ');
      }

      for (var i = 0; i < block.lines.length; i++) {
        final line = block.lines[i];
        var lineText = line.text.trim();

        // Detect list items
        if (RegExp(r'^[•·\-–—]\s').hasMatch(lineText)) {
          lineText = '- ${lineText.replaceFirst(RegExp(r'^[•·\-–—]\s+'), '')}';
        } else if (RegExp(r'^\d+[.)]\s').hasMatch(lineText)) {
          // Already numbered list format
        }

        buf.write(lineText);
        if (i < block.lines.length - 1) {
          // Within same block: check if line ends with punctuation
          if (RegExp(r'[.!?:;]$').hasMatch(lineText)) {
            buf.write('\n\n');
          } else {
            buf.write(' ');
          }
        }
      }

      buf.write('\n\n');
      prevBlockBottom = block.boundingBox.bottom;
    }

    return buf.toString().trim();
  }

  /// Heuristic: heading if block has 1-2 lines and avg line height is larger than median.
  bool _isLikelyHeading(TextBlock block, List<TextBlock> allBlocks) {
    if (block.lines.length > 2) return false;
    if (block.lines.isEmpty) return false;

    final blockLineHeight = block.boundingBox.height / block.lines.length;

    // Calculate median line height across all blocks
    final allHeights = <double>[];
    for (final b in allBlocks) {
      if (b.lines.isNotEmpty) {
        allHeights.add(b.boundingBox.height / b.lines.length);
      }
    }
    if (allHeights.length < 3) return false;
    allHeights.sort();
    final median = allHeights[allHeights.length ~/ 2];

    return blockLineHeight > median * 1.3;
  }

  /// Get text for TTS: text layer first, then OCR cache.
  String? getTextForPage(String bookId, int pageNumber, String? textLayerText) {
    if (textLayerText != null && textLayerText.trim().isNotEmpty) {
      return textLayerText;
    }
    return getCachedText(bookId, pageNumber);
  }

  /// Clear OCR cache for a book.
  Future<void> clearCache(String bookId) async {
    for (final box in [_textBox, _mdBox]) {
      final keys = box.keys.where((k) => k.toString().startsWith('${bookId}_')).toList();
      for (final key in keys) {
        await box.delete(key);
      }
    }
  }

  @override
  void dispose() {
    _recognizer.close();
    super.dispose();
  }
}
