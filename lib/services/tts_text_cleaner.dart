/// Cleans raw PDF text for TTS consumption.
/// Removes noise (headers, footers, page numbers) and joins broken lines.
class TtsTextCleaner {
  static String cleanPdfText(String raw) {
    var lines = raw.split('\n');

    // Remove likely headers/footers (short lines at start/end that are page numbers or repeated)
    lines = _removeHeadersFooters(lines);

    final buffer = StringBuffer();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trimRight();
      if (line.isEmpty) { buffer.write('\n\n'); continue; }
      buffer.write(line);
      final isLast = i == lines.length - 1;
      if (isLast) break;
      final nextLine = lines[i + 1].trim();
      if (nextLine.isEmpty) continue;
      final endsWithPunctuation = RegExp(r'[.!?:;。！？]\s*$').hasMatch(line);
      final nextStartsUpper = nextLine.isNotEmpty &&
          nextLine[0] == nextLine[0].toUpperCase() &&
          nextLine[0] != nextLine[0].toLowerCase();
      if (endsWithPunctuation || nextStartsUpper) { buffer.write('\n'); }
      else { buffer.write(' '); }
    }

    return buffer.toString()
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
  }

  /// Remove lines that look like page numbers, headers, or footers.
  static List<String> _removeHeadersFooters(List<String> lines) {
    if (lines.length < 5) return lines;
    final result = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      // Skip standalone page numbers
      if (RegExp(r'^\d{1,4}$').hasMatch(trimmed)) continue;
      // Skip lines that are just "Page X" or "- X -"
      if (RegExp(r'^[-–—]\s*\d+\s*[-–—]$').hasMatch(trimmed)) continue;
      if (RegExp(r'^(Page|Trang)\s+\d+', caseSensitive: false).hasMatch(trimmed)) continue;
      result.add(line);
    }
    return result;
  }

  /// Split text into sentences for per-sentence language detection.
  static List<String> splitSentences(String text) {
    if (text.trim().isEmpty) return [text.trim()];
    // Protect abbreviations
    var t = text;
    const abbrs = ['Mr.', 'Mrs.', 'Dr.', 'Ms.', 'Prof.', 'Sr.', 'Jr.', 'vs.', 'etc.', 'e.g.', 'i.e.', 'TS.', 'PGS.', 'GS.', 'ThS.'];
    for (final a in abbrs) {
      t = t.replaceAll(a, a.replaceAll('.', '\u0000'));
    }
    final parts = t
        .split(RegExp(r'(?<=[.!?。！？])\s+'))
        .map((s) => s.replaceAll('\u0000', '.').trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.isEmpty ? [text.trim()] : parts;
  }
}
