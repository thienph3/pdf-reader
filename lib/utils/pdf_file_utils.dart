import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Copies a PDF file to the app's persistent documents directory.
/// Returns the new path. If the file is already in the app directory, returns it as-is.
Future<String> copyPdfToAppDir(String sourcePath) async {
  final appDir = await getApplicationDocumentsDirectory();
  final pdfDir = Directory('${appDir.path}/pdfs');
  if (!pdfDir.existsSync()) pdfDir.createSync(recursive: true);

  // If already in our directory, skip copy
  if (sourcePath.startsWith(pdfDir.path)) return sourcePath;

  // Use hash of original path + filename to avoid collisions
  final fileName = sourcePath.split(Platform.pathSeparator).last;
  final hash = md5.convert(utf8.encode(sourcePath)).toString().substring(0, 8);
  final destPath = '${pdfDir.path}/${hash}_$fileName';

  // Skip if already copied
  final destFile = File(destPath);
  if (destFile.existsSync()) return destPath;

  await File(sourcePath).copy(destPath);
  return destPath;
}
