import 'package:html2md/html2md.dart' as html2md;

String htmlToMarkdown(String html) => html2md.convert(html);
