/// Converts simple EPUB HTML to Markdown for rendering.
String htmlToMarkdown(String html) {
  var s = html;
  // Headings
  for (var i = 6; i >= 1; i--) {
    s = s.replaceAllMapped(RegExp('<h$i[^>]*>(.*?)</h$i>', dotAll: true),
        (m) => '\n${'#' * i} ${m[1]!.trim()}\n');
  }
  // Bold
  s = s.replaceAllMapped(RegExp('<(strong|b)>(.*?)</\\1>', dotAll: true),
      (m) => '**${m[2]}**');
  // Italic
  s = s.replaceAllMapped(RegExp('<(em|i)>(.*?)</\\1>', dotAll: true),
      (m) => '*${m[2]}*');
  // List items
  s = s.replaceAllMapped(RegExp('<li[^>]*>(.*?)</li>', dotAll: true),
      (m) => '- ${m[1]!.trim()}\n');
  // Paragraphs
  s = s.replaceAll(RegExp(r'<p[^>]*>'), '\n\n');
  s = s.replaceAll('</p>', '');
  // Line breaks
  s = s.replaceAll(RegExp(r'<br\s*/?>'), '\n');
  // Strip remaining tags
  s = s.replaceAll(RegExp(r'<[^>]*>'), '');
  // Clean up whitespace
  s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return s.trim();
}
