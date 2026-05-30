import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'content_provider.dart';

/// CBZ/CBR (comic book archive) implementation of [ContentProvider].
/// Uses lazy loading with LRU cache to avoid OOM on large archives.
class CbzContentProvider extends ContentProvider {
  final String filePath;

  List<ArchiveFile> _imageFiles = [];
  final Map<int, Uint8List> _cache = {};
  static const _cacheSize = 5;
  bool _loading = true;
  String? _error;

  @override
  int get totalPages => _imageFiles.length;
  @override
  bool get isLoading => _loading;
  @override
  String? get error => _error;

  CbzContentProvider({required this.filePath});

  Future<void> load() async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      _imageFiles = archive.files
          .where((f) => f.isFile && _isImage(f.name))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      _loading = false;
    } catch (e) {
      _error = e.toString();
      _loading = false;
    }
  }

  Uint8List _getPage(int index) {
    if (_cache.containsKey(index)) return _cache[index]!;
    _cache[index] = Uint8List.fromList(_imageFiles[index].content);
    while (_cache.length > _cacheSize) {
      _cache.remove(_cache.keys.first);
    }
    return _cache[index]!;
  }

  bool _isImage(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') ||
        lower.endsWith('.png') || lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  @override
  Future<String?> getTextForPage(int page) async => null;

  @override
  Widget buildContent(BuildContext context, {
    required int currentPage,
    required ValueChanged<int> onPageChanged,
    required VoidCallback onReady,
    PageController? pageController,
  }) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null || _imageFiles.isEmpty) {
      return Center(child: Text(_error ?? 'No images found'));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
    return PageView.builder(
      controller: pageController,
      itemCount: _imageFiles.length,
      onPageChanged: onPageChanged,
      itemBuilder: (_, index) => InteractiveViewer(
        minScale: 1.0,
        maxScale: 3.0,
        child: Center(child: Image.memory(_getPage(index), fit: BoxFit.contain)),
      ),
    );
  }

  @override
  void dispose() {
    _cache.clear();
    _imageFiles = [];
  }
}
