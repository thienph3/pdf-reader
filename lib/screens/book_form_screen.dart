import 'package:flutter/material.dart';
import '../models/book.dart';
import '../l10n/app_strings.dart';
import 'book_form_ui_builder.dart';
import 'book_form_logic.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book;

  const BookFormScreen({super.key, this.book});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _notesCtrl;
  late BookFormLogic _logic;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _notesCtrl = TextEditingController(text: b?.notes ?? '');
    
    _logic = BookFormLogic(
      book: widget.book,
      titleCtrl: _titleCtrl,
      authorCtrl: _authorCtrl,
      notesCtrl: _notesCtrl,
      format: b?.format ?? BookFormat.ebook,
      filePath: b?.filePath,
      categoryId: b?.categoryId,
    );

    // Trigger rebuild on text changes so PopScope.canPop re-evaluates
    _titleCtrl.addListener(_onFieldChanged);
    _authorCtrl.addListener(_onFieldChanged);
    _notesCtrl.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    await _logic.pickFile(
      context: context,
      onFilePicked: (path) {
        setState(() {
          _logic.filePath = path;
        });
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (!_logic.hasChanges) return true;
    return await _logic.showDiscardDialog(context);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await _logic.save(
      context: context,
      onUpdate: (updated) {},
      onCreate: ({
        required String title,
        required String author,
        required BookFormat format,
        required String? filePath,
        required String? categoryId,
        required String notes,
      }) {},
      evictThumbnail: (bookId) {},
      getThumbnail: ({required String bookId, required String filePath, required int width}) {},
    );

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return PopScope(
      canPop: !_logic.hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_logic.isEditing ? s.editBook : s.addBook),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              BookFormUiBuilder.buildTitleField(
                controller: _titleCtrl,
                labelText: s.bookTitle,
                validator: (v) => v == null || v.trim().isEmpty
                    ? s.bookTitleRequired
                    : null,
              ),
              const SizedBox(height: 16),
              BookFormUiBuilder.buildAuthorField(
                controller: _authorCtrl,
                labelText: s.author,
              ),
              const SizedBox(height: 16),
              BookFormUiBuilder.buildFormatSelector(
                context: context,
                format: _logic.format,
                onChanged: (format) {
                  setState(() => _logic.format = format);
                },
              ),
              const SizedBox(height: 16),
              BookFormUiBuilder.buildCategoryPicker(
                context: context,
                categoryId: _logic.categoryId,
                onChanged: (v) => setState(() => _logic.categoryId = v),
              ),
              if (_logic.showFilePicker) ...[
                const SizedBox(height: 16),
                BookFormUiBuilder.buildFilePicker(
                  context: context,
                  filePath: _logic.filePath,
                  onPickFile: _pickFile,
                  fileNameFromPath: _logic.fileNameFromPath,
                ),
              ],
              const SizedBox(height: 16),
              BookFormUiBuilder.buildNotesField(
                controller: _notesCtrl,
                labelText: s.notes,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: Text(_logic.isEditing ? s.saveChanges : s.addBook),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
