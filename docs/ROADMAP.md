# PDF Reader — Product Roadmap

**Last updated:** 2026-05-31

---

## ✅ Completed

### P0 — Ship Blockers (2026-05-30)
1. ✅ Fix release signing (conditional keystore)
2. ✅ Fix package name → `com.thienph3.pdfreader`
3. ✅ Fix double-counting reading time
4. ✅ Fix managers recreated on every didChangeDependencies
5. ✅ Fix MainShell safe area (Scaffold.bottomNavigationBar)
6. ✅ Schema resilience + global ErrorWidget.builder
7. ✅ Fix non-atomic highlight color change
8. ✅ Optimize app icon (1.5MB → 58KB)
9. ✅ LRU thumbnail memory cache (max 25)
10. ✅ Set minSdk = 26
11. ✅ Localize all hardcoded English strings
12. ✅ PDF render error handling

### P1 — High Impact (2026-05-30)
13. ✅ Night/sepia/dark reading modes
14. ✅ "Continue Reading" card
15. ✅ Annotation export (Markdown)
16. ✅ Auto OCR → TTS fallback
17. ✅ PDF loading indicator
18. ✅ Responsive layout (NavigationRail ≥600dp, adaptive grid)
19. ✅ Page thumbnail grid navigation
20. ⏳ Reading reminders (deferred — needs native notification setup)
21. ✅ Fix pages read inflation
22. ✅ Fix TTS auto-advance race condition
23. ✅ iOS background audio entitlement

### P2 — Medium Impact (2026-05-31)
24. ✅ Unit tests (25 cases: Book model, BookService, ReadingLog)
25. ✅ Design tokens (spacing, elevation, theme-aware colors)
26. ✅ Haptic feedback (bookmark, highlight)
27. ✅ Accessibility (InkWell + Semantics on RecentBookItem)
28. ✅ Refactor PdfViewScreen (extracted _updateUiManagers)
29. ✅ Replace magic string filters (SmartFilter enum)
30. ✅ Validate import data (format index, path traversal)
31. ✅ Fix concurrent thumbnail requests (in-flight dedup)
32. ✅ OCR batch cancellation UI
33. ✅ Share highlights (share_plus)
34. ✅ Batch operations (long-press selection mode)
35. ✅ Manual backup/restore
36. ✅ DI flattened (single ServiceScope)

### P3 — Growth Differentiators (2026-05-31)
37. ⏳ Hive migration (deferred)
38. ✅ Highlight service facade
39. ✅ Category orphan cleanup on delete
40. ✅ Reading log retention (2-year cleanup)
41. ✅ Annotation types (underline, strikethrough)
42. ✅ Reading streaks & achievements (5 badges)
43. ⏳ EPUB support (deferred)
44. ⏳ Cloud backup (deferred)
45. ⏳ Full accessibility audit (deferred)
46. ⏳ Tablet split view (deferred)

### Infrastructure (2026-05-31)
- ✅ Register as PDF file handler (Android intent filter)
- ✅ Handle opened PDF (detect existing vs new, "Add to library?" prompt)
- ✅ Enforce 200 LOC/file limit
- ✅ Extract shared utils (render, dialogs, file utils, routing)
- ✅ Feature-based architecture restructure

---

## 🔜 Future Roadmap

### Next Sprint — Polish & Stability
| Item | Effort | Notes |
|------|--------|-------|
| Reading reminders (local notifications) | 1 day | Needs `flutter_local_notifications` + native setup |
| More unit tests (TTS, BookListManager) | 2 days | Target 60%+ coverage |
| Warm-start intent handling | 2h | Handle PDF opened while app already running |
| Full accessibility audit | 3 days | Screen reader, contrast, dynamic text |

### Medium Term — New Features
| Item | Effort | Notes |
|------|--------|-------|
| EPUB support | 1-2 weeks | New reader screen, `epub_view` package |
| Cloud backup (Google Drive / iCloud) | 1 week | Manual trigger, encrypted |
| Tablet split view | 2-3 days | Book list + reader side by side |
| Hive → Isar migration | 2-3 days | Needs repository pattern first |
| PDF form filling | 1 week | Evaluate pdfrx capabilities |

### Long Term — Differentiation
| Item | Effort | Notes |
|------|--------|-------|
| AI summarization (on-device) | 2 weeks | Summarize chapters/highlights |
| Handwriting annotations | 1 week | Freehand drawing on PDF pages |
| Reading groups / social | 2 weeks | Share progress with friends |
| Widget for home screen | 3 days | Show current book + streak |

---

## Architecture

```
lib/                          79 files, ~7,100 LOC
├── main.dart                 (entry point)
├── app/                      (shell, DI, splash)
├── core/                     (l10n, theme, utils, routing)
├── models/                   (Book, Category, Highlight, ReadingLog, ReadingGoal)
├── services/                 (12 services)
└── features/
    ├── library/              (book list, form, cards)
    │   ├── screens/
    │   ├── widgets/
    │   └── controllers/
    ├── reader/               (PDF viewer, TTS, OCR, highlights, bookmarks)
    │   ├── screens/
    │   ├── widgets/
    │   └── controllers/
    ├── stats/                (statistics, streaks, achievements)
    └── settings/             (settings, categories)
```

**Patterns:** Feature-based architecture, InheritedWidget DI (ServiceScope), StatefulWidget + controllers, 200 LOC/file limit.

**Stack:** Flutter 3.35+, pdfrx, Hive, flutter_tts, google_mlkit_text_recognition, share_plus.
