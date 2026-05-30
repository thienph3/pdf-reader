# PDF Reader

Offline PDF reader for Android/iOS with TTS, OCR, highlights, and reading statistics. Vietnamese-first with English support.

## Features

- **PDF Viewing** — Vertical/horizontal scroll, pinch-to-zoom, night/sepia/dark modes, page thumbnails
- **Annotations** — Highlights (6 colors), underline, strikethrough, bookmarks with notes, export as Markdown
- **Text-to-Speech** — Offline, auto language detection (vi/en/zh/ja/ko/th), background playback, speed control
- **OCR** — Google ML Kit for scanned PDFs, batch processing, feeds into TTS
- **Library** — Categories, smart collections, search, grid/list view, batch operations, backup/restore
- **Statistics** — Daily/weekly tracking, reading goals, streaks, achievements
- **System Integration** — Registered as PDF handler, copies files to app storage

## Getting Started

```bash
flutter pub get
flutter run
```

**Requirements:** Flutter 3.35+, Dart 3.9+

**Android:** minSdk 26. Release builds need a `keystore.jks` in `android/` with env vars `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`.

**iOS:** Background audio entitlement enabled for TTS.

## Architecture

```
lib/
├── main.dart
├── app/              Entry point, DI (ServiceScope), shell, splash
├── core/             Localization, theme, utils, routing
├── models/           Book, Category, Highlight, ReadingLog, ReadingGoal
├── services/         12 services (book, TTS, OCR, settings, etc.)
└── features/
    ├── library/      Book list, form, cards (screens/widgets/controllers)
    ├── reader/       PDF viewer, TTS, OCR, highlights, bookmarks
    ├── stats/        Statistics, streaks, achievements
    └── settings/     Settings, categories
```

**Patterns:** Feature-based modules, controller pattern, service layer, InheritedWidget DI, 200 LOC/file limit.

## Tech Stack

| Package | Purpose |
|---------|---------|
| pdfrx | PDF rendering |
| flutter_tts | Text-to-speech |
| google_mlkit_text_recognition | OCR |
| hive_flutter | Local storage |
| share_plus | Share highlights |
| file_picker | File selection |
| flutter_foreground_task | Background TTS (Android) |

## Testing

```bash
flutter test        # 25 unit tests
flutter analyze     # 0 errors, 0 warnings
```

## License

Private project.
