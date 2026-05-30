# PDF Reader — File Size & Complexity Analysis

**Updated:** 2026-05-31

---

## Summary

- **Total files:** 79 Dart files
- **Total LOC:** ~7,100
- **Average file size:** 90 LOC
- **Max file size:** 200 LOC (enforced, except app_strings.dart at 263)
- **Files > 150 LOC:** ~10 (all within limit)

---

## Largest Files (by LOC)

| File | LOC | Status |
|------|-----|--------|
| `core/l10n/app_strings.dart` | 263 | ✅ Exempt (localization) |
| `features/reader/screens/pdf_view_screen.dart` | ~195 | ✅ OK |
| `features/reader/controllers/pdf_view_dialogs_manager.dart` | ~197 | ✅ OK |
| `features/reader/controllers/pdf_highlight_manager.dart` | ~190 | ✅ OK |
| `features/library/screens/book_list_screen.dart` | ~185 | ✅ OK |
| `services/book_service.dart` | ~180 | ✅ OK |
| `features/reader/widgets/pdf_tts_panel.dart` | ~175 | ✅ OK |

---

## Complexity by Feature

| Feature | Files | Screens | Widgets | Controllers |
|---------|-------|---------|---------|-------------|
| Library | 18 | 2 | 6 | 10 |
| Reader | 25 | 1 | 15 | 9 |
| Stats | 2 | 1 | 1 | 0 |
| Settings | 4 | 2 | 2 | 0 |
| **Total** | **49** | **6** | **24** | **19** |

Plus: 4 app files, 8 core files, 5 models, 12 services = 79 total.

---

## File Size Guidelines

| Size | Assessment |
|------|-----------|
| < 100 LOC | ✅ Ideal |
| 100-150 LOC | ✅ Good |
| 150-200 LOC | ⚠️ Monitor — consider splitting if adding features |
| > 200 LOC | 🔴 Must split (except localization files) |

---

## When to Split a File

Split when:
1. File approaches 200 LOC
2. File has 2+ distinct responsibilities
3. A section could be reused elsewhere
4. Testing requires mocking internal parts

Don't split when:
1. It's a localization/constants file
2. Splitting would create circular imports
3. The code is cohesive (single responsibility, just long)
