import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../main.dart';
import '../models/book.dart';
import '../l10n/app_strings.dart';

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
  late BookFormat _format;
  String? _filePath;
  String? _categoryId;

  late final String _origTitle;
  late final String _origAuthor;
  late final String _origNotes;
  late final BookFormat _origFormat;
  late final String? _origFilePath;
  late final String? _origCategoryId;

  bool get _isEditing => widget.book != null;

  bool get _hasChanges {
    return _titleCtrl.text != _origTitle ||
        _authorCtrl.text != _origAuthor ||
        _notesCtrl.text != _origNotes ||
        _format != _origFormat ||
        _filePath != _origFilePath ||
        _categoryId != _origCategoryId;
  }

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _notesCtrl = TextEditingController(text: b?.notes ?? '');
    _format = b?.format ?? BookFormat.ebook;
    _filePath = b?.filePath;
    _categoryId = b?.categoryId;

    _origTitle = _titleCtrl.text;
    _origAuthor = _authorCtrl.text;
    _origNotes = _notesCtrl.text;
    _origFormat = _format;
    _origFilePath = _filePath;
    _origCategoryId = _categoryId;

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

  bool get _showFilePicker =>
      _format == BookFormat.ebook || _format == BookFormat.both;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final name = result.files.single.name;
      setState(() {
        _filePath = result.files.single.path;
        // Auto-fill title from filename if empty
        if (_titleCtrl.text.trim().isEmpty) {
          // Remove .pdf extension
          final title = name.endsWith('.pdf')
              ? name.substring(0, name.length - 4)
              : name;
          _titleCtrl.text = title;
        }
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final s = AppStrings.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.discardTitle),
        content: Text(s.discardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.continueEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.discard),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final svc = BookServiceScope.of(context);
    final thumbSvc = ThumbnailServiceScope.of(context);
    final path = _showFilePicker ? _filePath : null;

    if (_isEditing) {
      final updated = widget.book!.copyWith(
        title: _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        format: _format,
        filePath: () => path,
        categoryId: () => _categoryId,
        notes: _notesCtrl.text.trim(),
      );
      await svc.update(updated);
    } else {
      await svc.create(
        title: _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        format: _format,
        filePath: path,
        categoryId: _categoryId,
        notes: _notesCtrl.text.trim(),
      );
    }

    // Evict old thumbnail if file changed
    final origPath = _origFilePath;
    if (_isEditing && origPath != null && origPath != path) {
      thumbSvc.evict(widget.book!.id);
    }

    // Pre-render thumbnail for existing books when file changes
    if (_isEditing && path != null && path.isNotEmpty) {
      thumbSvc.getThumbnail(
          bookId: widget.book!.id, filePath: path, width: 300);
    }
    // New books: thumbnail will be lazy-loaded when card renders

    if (mounted) Navigator.pop(context, true);
  }

  String _fileNameFromPath(String path) {
    final sep = path.contains('\\') ? '\\' : '/';
    return path.split(sep).last;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? s.editBook : s.addBook),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: s.bookTitle,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? s.bookTitleRequired
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorCtrl,
                decoration: InputDecoration(
                  labelText: s.author,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFormatSelector(),
              const SizedBox(height: 16),
              _buildCategoryPicker(),
              if (_showFilePicker) ...[
                const SizedBox(height: 16),
                _buildFilePicker(),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(
                  labelText: s.notes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: Text(_isEditing ? s.saveChanges : s.addBook),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    final s = AppStrings.of(context);
    final catService = CategoryServiceScope.of(context);
    final categories = catService.getAll();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.category, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          initialValue: _categoryId,
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
          onChanged: (v) => setState(() => _categoryId = v),
        ),
      ],
    );
  }

  Widget _buildFormatSelector() {
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
          selected: {_format},
          onSelectionChanged: (selected) {
            setState(() => _format = selected.first);
          },
        ),
      ],
    );
  }

  Widget _buildFilePicker() {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.pdfFile, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.attach_file),
          label: Text(_filePath != null ? s.changeFile : s.pickFile),
        ),
        if (_filePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _fileNameFromPath(_filePath!),
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
