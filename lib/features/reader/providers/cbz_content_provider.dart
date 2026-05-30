import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'content_provider.dart';

/// CBZ/CBR (comic book archive) implementation of [ContentProvider].
/// Extracts images from zip and displays them in a PageView.
class CbzContentProvider extends ContentProvider {
  final String filePath;

  List<Uint8List> _pages = [];
  bool _loading = true;
  String? _error;

  @override
  int get totalPages => _pages.length;
  @override
  bool get isLoading => _loading;
  @override
  String? get error => _error;

  CbzContentProvider({required this.filePath});

  Future<void> load() async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      // Filter image files and sort by name
      final imageFiles = archive.files
          .where((f) => !f.isFile ? false : _isImage(f.name))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      _pages = imageFiles.map((f) => Uint8List.fromList(f.content)).toList();
      _loading = false;
    } catch (e) {
      _error = e.toString();
      _loading = false;
    }
  }

  bool _isImage(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') ||
        lower.endsWith('.png') || lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  @override
  Future<String?> getTextForPage(int page) async => null; // Comics have no text

  @override
  Widget buildContent(BuildContext context, {
    required int currentPage,
    required ValueChanged<int> onPageChanged,
    required VoidCallback onReady,
    PageController? pageController,
  }) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null || _pages.isEmpty) {
      return Center(child: Text(_error ?? 'No images found'));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
    return PageView.builder(
      controller: pageController,
      itemCount: _pages.length,
      onPageChanged: onPageChanged,
      itemBuilder: (_, index) => InteractiveViewer(
        minScale: 1.0,
        maxScale: 3.0,
        child: Center(child: Image.memory(_pages[index], fit: BoxFit.contain)),
      ),
    );
  }

  @override
  void dispose() => _pages.clear();
}
