/// Cleans raw PDF text for TTS consumption.
class TtsTextCleaner {
  static String cleanPdfText(String raw) {
    final lines = raw.split('\n');
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
}
