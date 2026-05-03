import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hive/hive.dart';

/// OCR service for scanned PDF pages.
/// Results are cached in Hive so OCR only runs once per page.
class OcrService extends ChangeNotifier {
  late Box<String> _box;
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  bool _isProcessing = false;
  int _currentPage = -1;
  int _totalQueued = 0;
  int _completedQueued = 0;

  bool get isProcessing => _isProcessing;
  int get currentPage => _currentPage;
  int get totalQueued => _totalQueued;
  int get completedQueued => _completedQueued;
  double get progress => _totalQueued > 0 ? _completedQueued / _totalQueued : 0;

  Future<void> init() async {
    _box = await Hive.openBox<String>('ocr_cache');
  }

  /// Get cached OCR text for a page. Returns null if not yet OCR'd.
  String? getCachedText(String bookId, int pageNumber) {
    final key = '${bookId}_$pageNumber';
    return _box.get(key);
  }

  /// Check if a page has been OCR'd.
  bool hasOcrText(String bookId, int pageNumber) {
    return _box.containsKey('${bookId}_$pageNumber');
  }

  /// OCR a single page from image bytes. Returns recognized text.
  Future<String> ocrPage({
    required String bookId,
    required int pageNumber,
    required Uint8List imageBytes,
  }) async {
    // Check cache first
    final cached = getCachedText(bookId, pageNumber);
    if (cached != null) return cached;

    _isProcessing = true;
    _currentPage = pageNumber;
    notifyListeners();

    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: const Size(1000, 1400), // approximate, ML Kit handles it
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 1000,
        ),
      );
      
      final result = await _recognizer.processImage(inputImage);
      final text = result.text;

      // Cache result
      await _box.put('${bookId}_$pageNumber', text);

      return text;
    } catch (e) {
      debugPrint('OCR error page $pageNumber: $e');
      return '';
    } finally {
      _isProcessing = false;
      _currentPage = -1;
      notifyListeners();
    }
  }

  /// OCR a page from a rendered PDF page image (png bytes).
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
      final inputImage = InputImage.fromBytes(
        bytes: pngBytes,
        metadata: InputImageMetadata(
          size: const Size(1000, 1400),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 1000,
        ),
      );

      final result = await _recognizer.processImage(inputImage);
      final text = result.text;
      await _box.put('${bookId}_$pageNumber', text);
      return text;
    } catch (e) {
      debugPrint('OCR error page $pageNumber: $e');
      return '';
    } finally {
      _isProcessing = false;
      _currentPage = -1;
      notifyListeners();
    }
  }

  /// Background OCR for multiple pages. Notifies progress.
  Future<void> ocrPagesInBackground({
    required String bookId,
    required List<int> pageNumbers,
    required Future<Uint8List?> Function(int pageNumber) renderPage,
  }) async {
    // Filter out already cached pages
    final toProcess = pageNumbers.where((p) => !hasOcrText(bookId, p)).toList();
    if (toProcess.isEmpty) return;

    _totalQueued = toProcess.length;
    _completedQueued = 0;
    notifyListeners();

    for (final pageNum in toProcess) {
      if (!_isProcessing) {
        // Allow cancellation
        break;
      }

      _currentPage = pageNum;
      notifyListeners();

      final imageBytes = await renderPage(pageNum);
      if (imageBytes != null) {
        await ocrFromPngBytes(
          bookId: bookId,
          pageNumber: pageNum,
          pngBytes: imageBytes,
        );
      }

      _completedQueued++;
      notifyListeners();

      // Small delay to not block UI
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _totalQueued = 0;
    _completedQueued = 0;
    _isProcessing = false;
    _currentPage = -1;
    notifyListeners();
  }

  /// Clear OCR cache for a book.
  Future<void> clearCache(String bookId) async {
    final keysToRemove = _box.keys
        .where((k) => k.toString().startsWith('${bookId}_'))
        .toList();
    for (final key in keysToRemove) {
      await _box.delete(key);
    }
  }

  /// Get text for a page: tries text layer first, then OCR cache.
  String? getTextForPage(String bookId, int pageNumber, String? textLayerText) {
    if (textLayerText != null && textLayerText.trim().isNotEmpty) {
      return textLayerText;
    }
    return getCachedText(bookId, pageNumber);
  }

  @override
  void dispose() {
    _recognizer.close();
    super.dispose();
  }
}
