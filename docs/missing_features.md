# PDF Reader — Tính năng và trạng thái

**Cập nhật:** 30/5/2026  
**Tổng quan:** Ứng dụng đọc PDF offline, quản lý thư viện cá nhân, hỗ trợ TTS + OCR.  
**Package:** `com.thienph3.pdfreader`  
**Codebase:** 48 Dart files, ~7,849 dòng code

---

## ✅ TÍNH NĂNG ĐÃ HOÀN THÀNH

### 📖 Đọc PDF
- PDF rendering (pdfrx 2.2.24)
- Cuộn dọc & cuộn ngang (snap-to-page)
- Velocity-aware scroll physics
- Pinch-to-zoom
- Table of Contents (TOC)
- Tìm kiếm văn bản trong PDF
- Text selection + copy
- Auto-save progress (debounced)

### ✏️ Highlight & Bookmark
- Tạo highlight từ text selection (6 màu)
- Tap on highlight → edit (đổi màu, ghi chú, xóa)
- FAB badge hiển thị số highlights trên page
- Danh sách highlights toàn bộ sách
- Bookmark trang (thêm/xóa/ghi chú)
- Persistent trong Hive

### 📚 Quản lý thư viện
- CRUD sách (title, author, format, notes)
- Category với màu sắc + filter chips
- Smart collections: Recently Added, Unread, Almost Finished, Frequently Read
- Grid/list view toggle
- Sort: recently updated, title A-Z, recently added
- Search by title/author
- Import/export JSON
- Thumbnail trang bìa (3-tier cache: memory → disk → render)
- Recently opened carousel
- Copy PDF vào app directory khi import (tránh invalid path)

### 🔊 Text-to-Speech
- Offline TTS (flutter_tts + native engine)
- Foreground service cho background playback (Android)
- Auto language detection (vi, en, zh, ja, ko, th)
- Speed control (0.5x – 2x)
- Per-page reading + auto-advance
- Text cleaning (nối dòng bị ngắt)
- Voice install check + hướng dẫn download
- Open TTS Settings (platform channel)

### 🔍 OCR
- Google ML Kit text recognition
- Cache kết quả trong Hive (plain text + markdown)
- OCR batch processing (toàn bộ sách)
- Text view mode (hiển thị OCR text dạng Markdown)
- Fallback cho TTS khi page không có text layer

### 📊 Thống kê
- Thời gian đọc hàng ngày
- Biểu đồ tuần
- Mục tiêu ngày (phút) + tháng (số sách)
- Tổng thời gian, sách hoàn thành, trang đã đọc

### ⚙️ Cài đặt
- Theme: System / Light / Dark
- Language: Tiếng Việt ↔ English
- Scroll direction
- Reading goals
- TTS language pack status

---

## 🔜 ĐÃ LÊN KẾ HOẠCH (xem ROADMAP.md)

### P0 — Sửa trước khi release
- Fix release signing (debug key)
- Fix package name (com.example.pdf_reader)
- Fix bugs: double-save, manager recreation, non-atomic highlight op
- Schema resilience, error handling
- Unbounded thumbnail cache fix

### P1 — Tính năng ưu tiên cao
- Night/sepia reading mode
- "Continue Reading" card
- Annotation export (Markdown)
- Page thumbnail grid navigation
- Responsive layout (tablet/desktop)
- Reading reminders

### P2 — Tính năng ưu tiên trung bình
- Unit tests (60%+ coverage)
- Share highlights
- Batch operations
- Backup/restore
- DI migration (InheritedWidget → Provider/Riverpod)

### P3 — Tương lai
- Hive migration (→ Isar/Drift)
- Additional annotation types (underline, strikethrough)
- Reading streaks & achievements
- EPUB support
- Cloud backup
- Tablet split view

---

## 📝 Ghi chú kỹ thuật

| Dependency | Version | Mục đích |
|-----------|---------|----------|
| pdfrx | ^2.2.24 | PDF rendering |
| flutter_tts | ^4.2.0 | Text-to-speech |
| flutter_foreground_task | ^8.13.4 | Background TTS |
| google_mlkit_text_recognition | ^0.14.0 | OCR |
| hive / hive_flutter | ^2.2.3 / ^1.1.0 | Local storage |
| file_picker | ^11.0.2 | File selection |
| path_provider | ^2.1.5 | App directory |
| uuid | ^4.5.1 | ID generation |
| crypto | ^3.0.6 | File hash (pdf copy) |
| flutter_markdown | ^0.7.7 | OCR text display |

**Architecture:** InheritedWidget DI, StatefulWidget + managers pattern  
**Storage:** Hive (unencrypted)  
**Platforms:** Android, iOS, macOS, Linux, Windows  
**Localization:** Vietnamese (default) + English
