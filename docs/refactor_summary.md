# PDF Reader — Architecture & Refactoring History

**Updated:** 2026-05-31

---

## Current Architecture

```
lib/                          79 files, ~7,100 LOC
├── main.dart                 (entry point → app/main.dart)
├── app/                      (4 files: main, service_scope, main_shell, splash)
├── core/                     (8 files: l10n, theme, utils, routing)
├── models/                   (5 files: book, category, highlight, reading_log, reading_goal)
├── services/                 (12 files: all business logic services)
└── features/
    ├── library/              (18 files)
    │   ├── screens/          (book_list_screen, book_form_screen)
    │   ├── widgets/          (book_card, cover, tile, recent_item)
    │   └── controllers/      (list_manager, selection, actions, form_logic, etc.)
    ├── reader/               (25 files)
    │   ├── screens/          (pdf_view_screen)
    │   ├── widgets/          (15: overlays, panels, sheets, builders)
    │   └── controllers/      (9: highlight, bookmark, TTS, OCR, text, dialogs)
    ├── stats/                (2 files: screen + widgets)
    └── settings/             (4 files: screens + widgets)
```

---

## Design Patterns Used

| Pattern | Where | Purpose |
|---------|-------|---------|
| Feature-based modules | `features/` | Encapsulate related code |
| Controller pattern | `controllers/` | Separate logic from UI |
| Service layer | `services/` | Business logic + data access |
| InheritedWidget DI | `app/service_scope.dart` | Dependency injection |
| Facade pattern | `highlight_service.dart` | Clean API over BookService |
| Mixin | `book_service_annotations.dart` | Split large service |
| LRU Cache | `pdf_text_cache.dart`, `thumbnail_service.dart` | Memory management |
| Builder pattern | `*_ui_builder.dart` | Construct complex widgets |

---

## Constraints

- **Max 200 LOC per file** (enforced)
- **Relative imports** throughout
- **Single responsibility** per file
- **No magic strings** (SmartFilter enum for collections)
- **Shared utils** for duplicate patterns (dialogs, render, file ops)

---

## Refactoring History

| Date | Change | Impact |
|------|--------|--------|
| 2026-05-30 | Extract managers from PdfViewScreen (1553→815 LOC) | 6 new manager files |
| 2026-05-30 | Split BookListScreen (610→402 LOC) | 4 new files |
| 2026-05-30 | Split BookFormScreen (350→166 LOC) | 2 new files |
| 2026-05-30 | Split BookCard (312→125 LOC) | 2 new files |
| 2026-05-31 | Enforce 200 LOC limit | 24 new files from 16 splits |
| 2026-05-31 | Extract shared utils | 4 util files, -70 LOC duplication |
| 2026-05-31 | Feature-based restructure | 62 files moved, all imports updated |

---

## Known Remaining Issues

| Issue | Severity | Notes |
|-------|----------|-------|
| `_uiBuilder`/`_dialogsManager` recreated in build() | Low | Extracted to method but still per-frame |
| No repository pattern | Medium | Services access Hive directly |
| Mixed state management | Medium | setState + ChangeNotifier + callbacks |
| IndexedStack keeps all tabs alive | Low | Acceptable for 4 tabs |
| `app_strings.dart` > 200 LOC (263) | Exempt | Localization file, splitting hurts readability |
