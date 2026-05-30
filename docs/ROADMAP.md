# PDF Reader — Product Roadmap

Based on Product Manager + Technical Lead + Design Lead + QA/QC Lead review (2026-05-30).

---

## P0 — Ship Blockers ✅ COMPLETED (2026-05-30)

### 1. ✅ Fix Release Signing
### 2. ✅ Fix Package Name → `com.thienph3.pdfreader`
### 3. ✅ Fix Double-Counting Reading Time
### 4. ✅ Fix Managers Recreated on Every didChangeDependencies
### 5. ✅ Fix MainShell Safe Area
### 6. ✅ Schema Resilience + Global Error Handler
### 7. ✅ Fix Non-Atomic Highlight Color Change
### 8. ✅ Optimize App Icon (1.5MB → 58KB)
### 9. ✅ Fix Unbounded Thumbnail Memory Cache (LRU 25)
### 10. ✅ Set Explicit minSdk = 26
### 11. ✅ Localize All Hardcoded English Strings
### 12. ✅ PDF Render Error Handling

---

## P1 — High Impact (Next 2–4 Weeks)

## P1 — High Impact ✅ COMPLETED (2026-05-30)

### 13. ✅ PDF Night/Sepia Reading Modes
### 14. ✅ "Continue Reading" Card
### 15. ✅ Annotation Export (Markdown)
### 16. ✅ Auto OCR → TTS Fallback (verified working)
### 17. ✅ Loading States (PDF loading indicator)
### 18. ✅ Responsive Layout (NavigationRail ≥600dp, responsive grid)
### 19. ✅ Page Thumbnail Grid Navigation
### 20. ⏳ Reading Reminder Notifications (deferred — needs native setup)
### 21. ✅ Fix Pages Read Inflation (done in P0)
### 22. ✅ Fix TTS Auto-Advance Race Condition
### 23. ✅ iOS Background Audio Entitlement

---

## P2 — Medium Impact ✅ COMPLETED (2026-05-31)

### 24. ✅ Unit Tests (25 tests: Book model, BookService, ReadingLog)
### 25. ✅ Design Tokens (spacing, elevation, theme-aware highlight colors)
### 26. ✅ Haptic Feedback (bookmark toggle, highlight creation)
### 27. ✅ Accessibility (InkWell + Semantics on RecentBookItem)
### 28. ✅ Refactor PdfViewScreen (extracted _updateUiManagers from build)
### 29. ✅ Replace Magic String Filters (SmartFilter enum)
### 30. ✅ Validate Import Data (format index, path traversal, required fields)
### 31. ✅ Fix Concurrent Thumbnail Requests (in-flight dedup)
### 32. ✅ OCR Batch Cancellation UI (cancel button)
### 33. ✅ Share Highlights (share_plus)
### 34. ✅ Batch Operations (long-press selection mode + bulk delete)
### 35. ✅ Manual Backup/Restore (JSON export/import in settings)
### 36. ✅ Migrate DI (flattened to single ServiceScope)

---

## P3 — Growth Differentiators (2–3 Months)

### 37. Hive Migration
- Target: `isar`, `drift`, or `objectbox`
- **Effort:** 2-3 days

### 38. Separate Highlights Storage
- Move from `List<Highlight>` inside Book to separate box keyed by `bookId_page`
- **Effort:** 1 day

### 39. Clean Up Category Orphans on Delete
- When category deleted, clear `categoryId` on affected books
- **Effort:** 1 hour

### 40. Reading Log Cleanup
- Add retention policy (e.g., keep 2 years) or export mechanism
- **Effort:** 2 hours

### 41. Additional Annotation Types
- Underline, strikethrough
- **Effort:** 2-3 days

### 42. Reading Streaks & Achievements
- **Effort:** 2-3 days

### 43. EPUB Support
- **Effort:** 1-2 weeks

### 44. Optional Cloud Backup
- **Effort:** 1 week

### 45. Accessibility Audit (Full)
- **Effort:** 3-5 days

### 46. Tablet Split View
- **Effort:** 2-3 days

---

## Known Bugs Tracker

| ID | Severity | Description | File | Status |
|----|----------|-------------|------|--------|
| BUG-1 | 🔴 Critical | Double-counting reading time (dispose + closeAndPop) | pdf_view_screen.dart | P0 #3 |
| BUG-2 | 🟠 High | Pages read inflated by .abs() and session reset | pdf_view_screen.dart | P1 #21 |
| BUG-3 | 🔴 Critical | Managers recreated on every didChangeDependencies | pdf_view_screen.dart | P0 #4 |
| BUG-4 | 🟡 Medium | TTS listener on potentially stale service instance | pdf_view_screen.dart | P2 #28 |
| BUG-5 | 🟡 Medium | `_textViewPageController` LateInitializationError risk | pdf_view_screen.dart | P2 #28 |
| BUG-6 | 🟢 Low | saveProgress always writes readingSeconds even when 0 | book_service.dart | Backlog |
| BUG-7 | 🔴 Critical | Non-atomic highlight color change (remove+add) | pdf_highlight_manager.dart | P0 #7 |
| BUG-8 | 🟢 Low | progressPercent shows 1% on first page (off-by-one) | book.dart | Backlog |

---

## Race Conditions Tracker

| ID | Severity | Description | Fix |
|----|----------|-------------|-----|
| RACE-1 | 🟠 High | Debounced save vs dispose save timing | P0 #3 |
| RACE-2 | 🟠 High | TTS auto-advance fires after manual page change | P1 #22 |
| RACE-3 | 🟡 Medium | Multiple _loadTextViewForPage for same page | Add loading flag per page |
| RACE-4 | 🟡 Medium | Concurrent thumbnail requests for same book | P2 #31 |
| RACE-5 | 🟢 Low | getAll() cache stale during iteration | Acceptable for single-isolate |

---

## Data Integrity Risks

| ID | Risk | Mitigation |
|----|------|-----------|
| DATA-1 | Non-atomic multi-step operations | P0 #7 (highlight), consider transaction wrapper |
| DATA-2 | Cache invalidation without notification | P2 #36 (DI migration with reactive state) |
| DATA-3 | Import without validation | P2 #30 |
| DATA-4 | Category deletion orphans book references | P3 #39 |
| DATA-5 | copyPdfToAppDir uses path hash not content hash | Document as known limitation |
| DATA-6 | Reading log grows unbounded | P3 #40 |

---

## UX Improvements (Ongoing)

| Issue | Fix | Effort |
|-------|-----|--------|
| No onboarding | First-run: 2-3 screens | 4h |
| Goal settings tap-to-cycle | Slider or number picker | 2h |
| No progress bar on book cards | Thin linear progress indicator | 1h |
| Quick category assign | Long-press → category picker | 4h |
| No page indicator in horizontal mode | Floating page number pill | 1h |
| Dismissible snaps back confusingly | Undo snackbar pattern | 2h |
| No confirmation after highlight | Brief snackbar | 30m |
| Auto-extract PDF metadata on pick | Fill title/author from PDF info | 3h |
| Merge Categories tab into Library | Move CRUD to settings/sheet | 3h |
| No hero animation book→reader | Shared element transition | 3h |

---

## Technical Debt Summary

| Severity | Count | Key Items |
|----------|-------|-----------|
| 🔴 CRITICAL | 5 | Release signing, package name, double-save bug, manager recreation, non-atomic highlight op |
| 🟠 HIGH | 8 | Zero tests, unbounded cache, God Object, no error handling, pages inflation, TTS race, no loading states, no responsive layout |
| 🟡 MEDIUM | 10 | Magic filters, full tree rebuild, OCR duplication, DI boilerplate, highlights in Book, no validation, concurrent thumbnails, no haptics, no design tokens, accessibility gaps |
| 🟢 LOW | 5 | Mixed comments, textViewPages leak, progressPercent off-by-one, saveProgress writes 0, SearchResultsBar flicker |

---

## Test Plan Summary

### Automated Tests Needed

| Layer | Suite | Cases | Priority |
|-------|-------|-------|----------|
| Unit | BookService | 17 cases (CRUD, progress, bookmarks, highlights, import/export) | P0 |
| Unit | Book Model | 7 cases (serialization, edge cases, computed properties) | P0 |
| Unit | TTS Language Detection | 10 cases (vi, en, zh, ja, ko, mixed, empty) | P1 |
| Unit | ReadingLogService | 6 cases (logging, aggregation, date boundaries) | P1 |
| Unit | BookListManager | 5 cases (filter, sort, smart collections) | P1 |
| Integration | PDF Reading Flow | 6 cases (open, navigate, save, close) | P2 |
| Integration | Import/Export | 3 cases (roundtrip, duplicates, malformed) | P2 |
| Integration | TTS Flow | 5 cases (start, advance, stop, manual change) | P2 |
| Edge Case | Boundaries | 8 cases (zero pages, long titles, concurrent ops) | P2 |

### Manual Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| MT-1 | Force-kill during reading | Progress saved up to last debounce |
| MT-2 | Low memory during OCR batch | Graceful pause/resume |
| MT-3 | Rapid bookmark toggle (10x) | Single bookmark created/removed |
| MT-4 | Screen rotation during PDF | Page position preserved |
| MT-5 | Import 1000+ books JSON | No ANR, progress shown |
| MT-6 | Delete book while PDF open | No crash, graceful close |
| MT-7 | Pick file from cloud provider | File copied to app dir correctly |
| MT-8 | Dark mode switch while reading | Theme updates without losing position |

---

## Implementation Order

```
Week 1:   ✅ P0 DONE
Week 2-4: ✅ P1 DONE (except reading reminders — deferred)
Week 5-8: ✅ P2 DONE
Month 3:  P3 items (Hive migration, highlights storage, streaks, EPUB, cloud, accessibility audit)
```

---

## Success Metrics

- **Stability:** Crash-free rate > 99.5%, 0 data loss incidents
- **Performance:** Cold start < 2s, 60fps scroll at 100+ books, PDF open < 1s
- **Data integrity:** Import/export roundtrip 100% fidelity
- **Retention:** 7-day > 40%, 30-day > 20%
- **Engagement:** Average session > 15 min
- **Accessibility:** WCAG AA compliance
- **Code health:** Test coverage > 60%, 0 critical bugs, 0 critical debt
- **Feature adoption:** TTS > 20%, highlights > 30%, night mode > 50%
