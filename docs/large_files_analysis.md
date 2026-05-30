# Phân tích file lớn — PDF Reader

**Cập nhật:** 30/5/2026

---

## Tổng quan

- **Total Dart files:** 48
- **Total LOC:** 7,849
- **Files > 300 dòng:** 4

---

## Files > 200 dòng (cần theo dõi)

| File | Dòng | Trạng thái | Ghi chú |
|------|------|-----------|---------|
| `pdf_view_screen.dart` | 815 | ⚠️ Cần refactor tiếp | God Object: TTS + OCR + text view + progress |
| `book_list_screen.dart` | 402 | ✅ Đã refactor | Đã tách manager + UI |
| `tts_service.dart` | 353 | ✅ Chấp nhận | Service phức tạp, logic hợp lý |
| `pdf_highlight_manager.dart` | 315 | ✅ Chấp nhận | Module chuyên biệt |
| `pdf_view_highlights_ui.dart` | 296 | ✅ Chấp nhận | UI highlights |
| `pdf_tts_panel.dart` | 291 | ⚠️ Có thể unused | Kiểm tra lại usage |
| `book_list_manager.dart` | 291 | ✅ Chấp nhận | Filter/sort logic |
| `book_list_ui.dart` | 288 | ✅ Chấp nhận | UI components |
| `settings_screen.dart` | 279 | ✅ Chấp nhận | |
| `book_card_ui_builder.dart` | 256 | ✅ Chấp nhận | Card UI |
| `stats_screen.dart` | 242 | ✅ Chấp nhận | |
| `book_service.dart` | 229 | ✅ Chấp nhận | |
| `category_screen.dart` | 215 | ✅ Chấp nhận | |
| `pdf_view_ui_builder.dart` | 199 | ✅ Chấp nhận | |
| `pdf_text_selection_manager.dart` | 182 | ✅ Chấp nhận | |
| `ocr_service.dart` | 177 | ✅ Chấp nhận | |
| `pdf_view_dialogs_manager.dart` | 173 | ✅ Chấp nhận | |
| `book_form_ui_builder.dart` | 170 | ✅ Chấp nhận | |
| `book_form_screen.dart` | 166 | ✅ Chấp nhận | |
| `book_form_logic.dart` | 165 | ✅ Chấp nhận | |

---

## Ưu tiên refactor tiếp

### 1. `pdf_view_screen.dart` (815 dòng) — HIGH
**Vấn đề:**
- Vẫn chứa TTS logic (toggle, speak, auto-advance)
- OCR batch processing + text view mode
- Progress saving + reading timer
- 20+ instance variables

**Đề xuất tách:**
- `PdfTtsController` — TTS toggle, speak page, auto-advance, listener
- `PdfOcrHelper` — OCR batch, text view loading, render-to-PNG logic
- Giữ `pdf_view_screen.dart` < 400 dòng

**Prerequisite:** Unit tests cho TTS và OCR logic trước

### 2. `tts_service.dart` (353 dòng) — LOW
- Logic phức tạp nhưng cohesive (language detection, text cleaning, playback)
- Chấp nhận được ở kích thước hiện tại
- Có thể tách `TtsLanguageDetector` nếu cần test riêng

---

## Guideline kích thước file

| Kích thước | Đánh giá |
|-----------|----------|
| < 200 dòng | ✅ Tốt |
| 200-400 dòng | ✅ Chấp nhận nếu cohesive |
| 400-600 dòng | ⚠️ Cần xem xét tách |
| > 600 dòng | 🔴 Cần refactor |
