import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/book.dart';
import '../main.dart';

class BookFormUiBuilder {
  static Widget buildTitleField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  static Widget buildAuthorField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  static Widget buildNotesField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  static Widget buildCategoryPicker({
    required BuildContext context,
    required String? categoryId,
    required ValueChanged<String?> onChanged,
  }) {
    final s = AppStrings.of(context);
    final catService = CategoryServiceScope.of(context);
    final categories = catService.getAll();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.category, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          initialValue: categoryId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: Text(s.selectCategory),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(s.noCategory),
            ),
            ...categories.map((cat) => DropdownMenuItem<String?>(
                  value: cat.id,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: Color(cat.colorValue),
                      ),
                      const SizedBox(width: 8),
                      Text(cat.name),
                    ],
                  ),
                )),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  static Widget buildFormatSelector({
    required BuildContext context,
    required BookFormat format,
    required ValueChanged<BookFormat> onChanged,
  }) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.bookType, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<BookFormat>(
          segments: [
            ButtonSegment(
              value: BookFormat.paper,
              label: Text(s.paper),
              icon: const Icon(Icons.menu_book),
            ),
            ButtonSegment(
              value: BookFormat.ebook,
              label: Text(s.ebook),
              icon: const Icon(Icons.tablet_android),
            ),
            ButtonSegment(
              value: BookFormat.both,
              label: Text(s.both),
              icon: const Icon(Icons.library_books),
            ),
          ],
          selected: {format},
          onSelectionChanged: (selected) {
            onChanged(selected.first);
          },
        ),
      ],
    );
  }

  static Widget buildFilePicker({
    required BuildContext context,
    required String? filePath,
    required VoidCallback onPickFile,
    required String Function(String) fileNameFromPath,
  }) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.pdfFile, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPickFile,
          icon: const Icon(Icons.attach_file),
          label: Text(filePath != null ? s.changeFile : s.pickFile),
        ),
        if (filePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    fileNameFromPath(filePath),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}