import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../main.dart';
import '../models/book.dart';

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

  // Original values for dirty checking (#4)
  late final String _origTitle;
  late final String _origAuthor;
  late final String _origNotes;
  late final BookFormat _origFormat;
  late final String? _origFilePath;

  bool get _isEditing => widget.book != null;

  /// Compare current form state against original values.
  bool get _hasChanges {
    return _titleCtrl.text != _origTitle ||
        _authorCtrl.text != _origAuthor ||
        _notesCtrl.text != _origNotes ||
        _format != _origFormat ||
        _filePath != _origFilePath;
  }

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _notesCtrl = TextEditingController(text: b?.notes ?? '');
    _format = b?.format ?? BookFormat.paper;
    _filePath = b?.filePath;

    _origTitle = _titleCtrl.text;
    _origAuthor = _authorCtrl.text;
    _origNotes = _notesCtrl.text;
    _origFormat = _format;
    _origFilePath = _filePath;

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
      setState(() => _filePath = result.files.single.path);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Huỷ thay đổi?'),
        content: const Text('Bạn có thay đổi chưa lưu. Muốn huỷ bỏ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tiếp tục sửa'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Huỷ bỏ'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final svc = BookServiceScope.of(context);
    final path = _showFilePicker ? _filePath : null;

    if (_isEditing) {
      final updated = widget.book!.copyWith(
        title: _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        format: _format,
        filePath: () => path,
        notes: _notesCtrl.text.trim(),
      );
      await svc.update(updated);
    } else {
      await svc.create(
        title: _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        format: _format,
        filePath: path,
        notes: _notesCtrl.text.trim(),
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  String _fileNameFromPath(String path) {
    final sep = path.contains('\\') ? '\\' : '/';
    return path.split(sep).last;
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(_isEditing ? 'Sửa sách' : 'Thêm sách'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên sách *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Vui lòng nhập tên sách'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tác giả',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFormatSelector(),
              if (_showFilePicker) ...[
                const SizedBox(height: 16),
                _buildFilePicker(),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Lưu thay đổi' : 'Thêm sách'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Loại sách', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<BookFormat>(
          segments: const [
            ButtonSegment(
              value: BookFormat.paper,
              label: Text('Giấy'),
              icon: Icon(Icons.menu_book),
            ),
            ButtonSegment(
              value: BookFormat.ebook,
              label: Text('Ebook'),
              icon: Icon(Icons.tablet_android),
            ),
            ButtonSegment(
              value: BookFormat.both,
              label: Text('Cả hai'),
              icon: Icon(Icons.library_books),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('File PDF', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.attach_file),
          label: Text(_filePath != null ? 'Đổi file' : 'Chọn file PDF'),
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
