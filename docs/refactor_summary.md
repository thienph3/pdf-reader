# Refactor Summary — PDF Reader

**Cập nhật:** 30/5/2026

---

## Refactor đã thực hiện

### PdfViewScreen (từ 1553 → 815 dòng)

File gốc quá lớn, đã tách thành các module:

| Module | Dòng | Trách nhiệm |
|--------|------|-------------|
| `pdf_view_screen.dart` | 815 | Orchestrator chính (vẫn còn lớn) |
| `pdf_highlight_manager.dart` | 315 | Quản lý highlight: vẽ, cache text, CRUD |
| `pdf_bookmark_manager.dart` | 87 | Quản lý bookmark: thêm/xóa/ghi chú |
| `pdf_text_selection_manager.dart` | 182 | Text selection + context menu highlight |
| `pdf_view_ui_builder.dart` | 199 | Build app bar, search bar, FAB |
| `pdf_view_dialogs_manager.dart` | 173 | TOC, reader actions, TTS speed dialogs |
| `pdf_view_highlights_ui.dart` | 296 | Highlights list, edit menu, page highlights |
| `pdf_view_search_ui.dart` | 41 | Paint search matches |
| `pdf_tts_panel.dart` | 291 | TTS panel UI (unused — TTS inline in screen) |

### BookListScreen (từ 610 → 402 dòng)

Tách thành:

| Module | Dòng | Trách nhiệm |
|--------|------|-------------|
| `book_list_screen.dart` | 402 | Screen chính + state |
| `book_list_manager.dart` | 291 | Filter, sort, smart collections |
| `book_list_ui.dart` | 288 | Grid/list view, empty state, collections UI |
| `book_actions_manager.dart` | 129 | Open, edit, delete, import/export actions |

### BookFormScreen (từ 350 → 166 dòng)

Tách thành:

| Module | Dòng | Trách nhiệm |
|--------|------|-------------|
| `book_form_screen.dart` | 166 | Screen + state |
| `book_form_logic.dart` | 165 | Form logic, validation, save, file pick |
| `book_form_ui_builder.dart` | 170 | Form field widgets |

### BookCard (từ 312 → 125 dòng)

Tách thành:

| Module | Dòng | Trách nhiệm |
|--------|------|-------------|
| `book_card.dart` | 125 | Widget chính |
| `book_card_logic.dart` | 59 | Thumbnail loading logic |
| `book_card_ui_builder.dart` | 256 | Card UI (cover, info, badges) |

---

## Vấn đề còn tồn tại

### PdfViewScreen vẫn là God Object (815 dòng)
- Vẫn chứa: TTS logic, OCR batch, text view mode, progress saving, page snapping
- **Cần tiếp tục tách:** `PdfTtsController`, `PdfOcrHelper`
- **Prerequisite:** Unit tests trước khi refactor tiếp

### BookListManager dùng magic strings
- `'added:recent'`, `'status:unread'` inject vào search controller
- Cần thay bằng enum-based `FilterState`

### Managers recreated mỗi build()
- ~~`_uiBuilder` và `_dialogsManager` tạo mới trong `build()` và `didChangeDependencies()`~~
- ✅ Fixed: `didChangeDependencies` chỉ update khi service instance thay đổi
- ⚠️ `_uiBuilder`/`_dialogsManager` vẫn tạo mới trong `build()` — cần move vào state

---

## Metrics

| Metric | Trước | Sau |
|--------|-------|-----|
| Dart files | ~25 | 48 |
| Total LOC | ~5,500 | 7,849 |
| Largest file | 1,553 dòng | 815 dòng |
| Files > 300 dòng | 6 | 4 |
