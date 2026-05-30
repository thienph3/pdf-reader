# PDF Reader — Features & Status

**Updated:** 2026-05-31  
**Package:** `com.thienph3.pdfreader`  
**Architecture:** Feature-based (79 files, ~7,100 LOC)

---

## ✅ Implemented Features

### 📖 PDF Reading
- PDF rendering (pdfrx 2.2.24)
- Vertical & horizontal scroll (snap-to-page)
- Velocity-aware scroll physics
- Pinch-to-zoom
- Night / sepia / dark reading modes
- Table of Contents (TOC)
- Text search with results bar
- Text selection + copy
- Page thumbnail grid navigation
- Auto-save progress (debounced)
- Loading indicator before viewer ready
- Error handling for corrupted/missing PDFs
- Register as system PDF handler (Android intent filter)
- Detect existing vs new PDF on open

### ✏️ Annotations
- Highlights (6 colors) from text selection
- Underline & strikethrough annotation types
- Tap highlight → edit (color, note, delete)
- FAB badge with highlight count per page
- Highlights list (per page + full book)
- Bookmarks with notes
- Share highlights via share_plus
- Export annotations as Markdown
- Haptic feedback on create

### 📚 Library Management
- CRUD books (title, author, format, notes)
- Categories with colors + filter chips
- Smart collections (Recently Added, Unread, Almost Finished, Frequently Read)
- SmartFilter enum (no magic strings)
- Grid/list view toggle
- Sort: recently updated, title A-Z, recently added
- Search by title/author
- Batch operations (long-press selection mode)
- Import/export JSON with validation
- Backup/restore in settings
- Copy PDF to app directory on import
- Thumbnail (3-tier LRU cache: memory 25 → disk → render)
- Recently opened carousel
- "Continue Reading" card
- Responsive grid (2/3/4 columns by screen width)

### 🔊 Text-to-Speech
- Offline TTS (flutter_tts + native engine)
- Foreground service for background playback (Android)
- iOS background audio entitlement
- Auto language detection (vi, en, zh, ja, ko, th)
- Speed control (0.5x – 2x)
- Per-page reading + auto-advance (race condition fixed)
- Text cleaning (join broken lines)
- Voice install check + guidance
- Auto OCR → TTS fallback for scanned pages

### 🔍 OCR
- Google ML Kit text recognition
- Cached results in Hive (plain text + markdown)
- Batch processing with cancel button
- Text view mode (Markdown display)
- Feeds into TTS pipeline

### 📊 Statistics & Gamification
- Daily reading time tracking
- Weekly chart
- Daily goal (minutes) + monthly goal (books)
- Reading streaks (current + longest)
- 5 achievements (First Book, 7-Day Streak, 30-Day Streak, 100 Pages, Bookworm)
- Reading log retention (auto-cleanup > 2 years)

### ⚙️ Settings & Platform
- Theme: System / Light / Dark
- Language: Tiếng Việt ↔ English
- Scroll direction preference
- Reading goals
- TTS language pack status
- Responsive layout (NavigationRail ≥ 600dp)
- Category orphan cleanup on delete

---

## ⏳ Planned (Not Yet Implemented)

| Feature | Priority | Effort |
|---------|----------|--------|
| Reading reminders (notifications) | High | 1 day |
| EPUB support | Medium | 1-2 weeks |
| Cloud backup (Drive/iCloud) | Medium | 1 week |
| Tablet split view | Medium | 2-3 days |
| Hive → Isar migration | Medium | 2-3 days |
| Full accessibility audit | Medium | 3 days |
| Warm-start intent handling | Low | 2 hours |

---

## Tech Stack

| Dependency | Purpose |
|-----------|---------|
| pdfrx ^2.2.24 | PDF rendering |
| flutter_tts ^4.2.0 | Text-to-speech |
| flutter_foreground_task ^8.13.4 | Background TTS (Android) |
| google_mlkit_text_recognition ^0.14.0 | OCR |
| hive / hive_flutter | Local storage |
| file_picker ^11.0.2 | File selection |
| path_provider ^2.1.5 | App directory |
| share_plus ^10.0.0 | Share highlights |
| uuid ^4.5.1 | ID generation |
| crypto ^3.0.6 | File hash |
| flutter_markdown ^0.7.7 | OCR text display |

---

## Quality Metrics

- **Files:** 79 Dart files (max 200 LOC each)
- **Tests:** 25 unit tests (Book model, BookService, ReadingLog)
- **Lint:** 0 errors, 0 warnings
- **Architecture:** Feature-based with controllers/widgets/screens separation
- **Platforms:** Android (minSdk 26), iOS, macOS, Linux, Windows
- **Localization:** Vietnamese (default) + English
