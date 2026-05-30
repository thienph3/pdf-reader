import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/features/reader/providers/text_content_provider.dart';

void main() {
  test('detects file format from extension', () {
    expect('test.pdf'.split('.').last, 'pdf');
    expect('book.epub'.split('.').last, 'epub');
    expect('notes.txt'.split('.').last, 'txt');
    expect('comic.cbz'.split('.').last, 'cbz');
  });

  test('TextContentProvider splits text into pages', () async {
    final tmp = await Directory.systemTemp.createTemp('reader_test');
    final file = File('${tmp.path}/test.txt');
    final text = 'A' * 5000;
    await file.writeAsString(text);

    final provider = TextContentProvider(filePath: file.path);
    await provider.load();

    expect(provider.error, isNull);
    expect(provider.totalPages, greaterThan(1));
    expect(await provider.getTextForPage(0), isNotNull);

    await tmp.delete(recursive: true);
  });

  test('TextContentProvider reports error for missing file', () async {
    final provider = TextContentProvider(filePath: '/nonexistent/file.txt');
    await provider.load();

    expect(provider.error, isNotNull);
    expect(provider.totalPages, 0);
  });
}
