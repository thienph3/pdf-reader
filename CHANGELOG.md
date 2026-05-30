# Changelog

## Unreleased

### Added
- EPUB support with HTML-to-Markdown rendering via flutter_markdown
- TXT/Markdown file reading with page splitting
- CBZ/CBR comic book viewer with pinch-to-zoom
- ContentProvider abstraction for format-agnostic reading
- Format-agnostic bookmark toggle (works for EPUB, TXT, CBZ)
- `htmlToMarkdown` utility for EPUB content conversion
- Night/sepia/dark reading modes
- "Continue Reading" card on home screen
- Annotation export as Markdown
- Page thumbnail grid navigation
- Responsive layout (NavigationRail on tablets)
- Reading streaks & achievements (5 badges)
- Underline & strikethrough annotation types
- Share highlights via share_plus
- Batch operations (long-press selection mode)
- Manual backup/restore in settings
- OCR batch cancel button
- Register as system PDF handler (Android)
- Auto-detect existing vs new PDF on open
- PDF loading indicator
- iOS background audio entitlement

### Fixed
- Double-counting reading time on close
- Pages read inflated by backward navigation
- TTS auto-advance race condition
- Non-atomic highlight color change (data loss risk)
- Managers recreated on every didChangeDependencies
- MainShell safe area on notched devices
- Unbounded thumbnail memory cache (now LRU 25)
- Concurrent thumbnail requests rendering same PDF twice
- Category deletion leaving orphan references
- Import accepting invalid/malicious data

### Changed
- Package name: `com.example.pdf_reader` → `com.thienph3.pdfreader`
- Release signing: conditional keystore (not debug key)
- minSdk set to 26 explicitly
- App icon optimized (1.5MB → 58KB)
- All hardcoded English strings localized
- Magic string filters replaced with SmartFilter enum
- DI flattened to single ServiceScope
- Feature-based folder structure
- 200 LOC/file limit enforced
- Shared utils extracted (dialogs, render, file ops)

## 1.0.0 (Initial)

- PDF viewing with pdfrx
- Highlights, bookmarks
- TTS with language detection
- OCR for scanned PDFs
- Library management with categories
- Reading statistics
- Vietnamese + English localization
