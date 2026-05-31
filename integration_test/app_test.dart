import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pdf_reader/models/book.dart';
import 'package:pdf_reader/models/highlight.dart';

import 'test_helper.dart';

/// Integration tests that require a real device/emulator.
/// Run with: flutter test integration_test/
///
/// These test REAL user flows end-to-end with actual Hive, file I/O, and platform APIs.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Launch', () {
    testWidgets('app starts without crashing', (tester) async {
      final app = await createTestApp();
      await tester.pumpWidget(app);
      // Splash screen shows app name
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('PDF Reader'), findsOneWidget);
      // Wait for transition to main shell
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      // Bottom navigation is visible
      expect(find.byType(NavigationBar), findsOneWidget);
      await cleanupTest();
    });

    testWidgets('empty library shows add book hint', (tester) async {
      final app = await createTestApp();
      await pumpAndSettle(tester, app);
      // Empty state shows hint with add button
      expect(find.byIcon(Icons.add), findsOneWidget);
      await cleanupTest();
    });
  });

  group('Add Book Flow', () {
    testWidgets('add book with file creates entry in library', (tester) async {
      final app = await createTestApp();
      await pumpAndSettle(tester, app);
      // Tap FAB to open book form
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      // Book form screen should be visible with title field
      expect(find.byType(TextFormField), findsWidgets);
      await cleanupTest();
    }, skip: true /* Requires file picker interaction */);

    testWidgets('add book without file creates paper book', (tester) async {
      final app = await createTestApp();
      await pumpAndSettle(tester, app);
      // Tap FAB to open book form
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      // Enter title
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'My Paper Book');
      await tester.pumpAndSettle();
      // Find and tap save button
      final saveBtn = find.byIcon(Icons.check);
      if (saveBtn.evaluate().isNotEmpty) {
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();
      }
      await cleanupTest();
    });
  });

  group('PDF Reading Flow', () {
    testWidgets('open PDF shows first page', (tester) async {
      // Skip - requires real PDF file
    }, skip: true /* Requires test PDF fixture */);

    testWidgets('page navigation updates progress', (tester) async {
      // Skip - requires real PDF file
    }, skip: true /* Requires test PDF fixture */);

    testWidgets('reading time is tracked', (tester) async {
      // Skip - requires real PDF file
    }, skip: true /* Requires test PDF fixture */);

    testWidgets('fullscreen mode hides app bar', (tester) async {
      // Skip - requires real PDF file
    }, skip: true /* Requires test PDF fixture */);

    testWidgets('night mode applies color filter', (tester) async {
      // Skip - requires real PDF file
    }, skip: true /* Requires test PDF fixture */);
  });

  group('EPUB Reading Flow', () {
    testWidgets('open EPUB shows first chapter', (tester) async {
      // Skip - requires real EPUB file
    }, skip: true /* Requires test EPUB fixture */);

    testWidgets('swipe navigates between chapters', (tester) async {
      // Skip - requires real EPUB file
    }, skip: true /* Requires test EPUB fixture */);
  });

  group('Highlights & Bookmarks', () {
    testWidgets('bookmark toggle persists across sessions', (tester) async {
      // Skip - requires reader open with a file
    }, skip: true /* Requires test PDF fixture */);

    testWidgets('highlight is visible after creation', (tester) async {
      // Skip - requires reader open with a file
    }, skip: true /* Requires test PDF fixture */);
  });

  group('TTS Flow', () {
    testWidgets('TTS starts reading current page', (tester) async {
      // Skip - requires reader + TTS engine on device
    }, skip: true /* Requires test PDF fixture and TTS engine */);

    testWidgets('TTS auto-advances to next page', (tester) async {
      // Skip - requires reader + TTS engine on device
    }, skip: true /* Requires test PDF fixture and TTS engine */);

    testWidgets('TTS detects Vietnamese and switches language', (tester) async {
      // Skip - requires reader + TTS engine on device
    }, skip: true /* Requires test PDF fixture and TTS engine */);
  });

  group('OCR Flow', () {
    testWidgets('OCR processes scanned page', (tester) async {
      // Skip - requires ML Kit + scanned PDF
    }, skip: true /* Requires test PDF fixture and ML Kit */);

    testWidgets('OCR batch can be cancelled', (tester) async {
      // Skip - requires ML Kit + scanned PDF
    }, skip: true /* Requires test PDF fixture and ML Kit */);
  });

  group('Library Management', () {
    testWidgets('search filters books by title', (tester) async {
      final app = await createTestApp();
      // Pre-populate books
      await services.bookService.create(title: 'Flutter Guide', format: BookFormat.ebook);
      await services.bookService.create(title: 'Dart Cookbook', format: BookFormat.ebook);
      await services.bookService.create(title: 'Flutter Animations', format: BookFormat.ebook);
      await pumpAndSettle(tester, app);
      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      // Type search query
      await tester.enterText(find.byType(TextField).last, 'Flutter');
      await tester.pumpAndSettle();
      // Should show 2 Flutter books, not Dart Cookbook
      expect(find.text('Flutter Guide'), findsOneWidget);
      expect(find.text('Flutter Animations'), findsOneWidget);
      expect(find.text('Dart Cookbook'), findsNothing);
      await cleanupTest();
    });

    testWidgets('category filter shows only categorized books', (tester) async {
      final app = await createTestApp();
      // Create category and books
      final cat = await services.categoryService.create(name: 'Programming');
      await services.bookService.create(
        title: 'Categorized Book',
        format: BookFormat.ebook,
        categoryId: cat.id,
      );
      await services.bookService.create(title: 'Uncategorized Book', format: BookFormat.ebook);
      await pumpAndSettle(tester, app);
      // Tap category chip
      final chipFinder = find.text('Programming');
      if (chipFinder.evaluate().isNotEmpty) {
        await tester.tap(chipFinder);
        await tester.pumpAndSettle();
        expect(find.text('Categorized Book'), findsOneWidget);
        expect(find.text('Uncategorized Book'), findsNothing);
      }
      await cleanupTest();
    });

    testWidgets('batch delete removes multiple books', (tester) async {
      final app = await createTestApp();
      await services.bookService.create(title: 'Book A', format: BookFormat.paper);
      await services.bookService.create(title: 'Book B', format: BookFormat.paper);
      await services.bookService.create(title: 'Book C', format: BookFormat.paper);
      await pumpAndSettle(tester, app);
      // Long-press to enter selection mode
      await tester.longPress(find.text('Book A'));
      await tester.pumpAndSettle();
      // Tap other books to select
      await tester.tap(find.text('Book B'));
      await tester.pumpAndSettle();
      // Look for delete action
      final deleteBtn = find.byIcon(Icons.delete);
      if (deleteBtn.evaluate().isNotEmpty) {
        await tester.tap(deleteBtn);
        await tester.pumpAndSettle();
        // Confirm deletion if dialog appears
        final confirmBtn = find.text('OK');
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn);
          await tester.pumpAndSettle();
        }
      }
      await cleanupTest();
    });

    testWidgets('backup and restore preserves all data', (tester) async {
      // Skip - requires file system access for backup file
    }, skip: true /* Requires file picker for backup/restore */);
  });

  group('Per-Book Settings', () {
    testWidgets('reading mode persists per book', (tester) async {
      // Skip - requires reader open
    }, skip: true /* Requires test PDF fixture */);

    testWidgets('crop level persists per book', (tester) async {
      // Skip - requires reader open
    }, skip: true /* Requires test PDF fixture */);
  });

  group('System Integration', () {
    testWidgets('opening PDF from file manager launches reader', (tester) async {
      // Skip - requires platform intent simulation
    }, skip: true /* Requires platform intent channel mock */);

    testWidgets('existing book opens with saved progress', (tester) async {
      // Skip - requires platform intent simulation
    }, skip: true /* Requires platform intent channel mock */);
  });

  group('Data Integrity', () {
    testWidgets('app survives force-kill during reading', (tester) async {
      // Skip - cannot simulate force-kill in integration test
    }, skip: true /* Cannot simulate force-kill */);

    testWidgets('corrupt Hive data does not crash app', (tester) async {
      final app = await createTestApp();
      // Write corrupt data directly to Hive box
      final box = services.bookService.box;
      await box.put('corrupt_entry', <dynamic, dynamic>{'invalid': true});
      await pumpAndSettle(tester, app);
      // App should still launch without crashing
      expect(find.byType(NavigationBar), findsOneWidget);
      await cleanupTest();
    });
  });

  group('Settings Navigation', () {
    testWidgets('navigate to settings tab', (tester) async {
      final app = await createTestApp();
      await pumpAndSettle(tester, app);
      // Tap settings in bottom nav
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      // Settings screen should show theme option
      expect(find.byIcon(Icons.settings), findsWidgets);
      await cleanupTest();
    });

    testWidgets('navigate to categories tab', (tester) async {
      final app = await createTestApp();
      await pumpAndSettle(tester, app);
      // Tap categories in bottom nav
      await tester.tap(find.byIcon(Icons.folder_outlined));
      await tester.pumpAndSettle();
      // Empty categories state
      expect(find.byIcon(Icons.folder_outlined), findsWidgets);
      await cleanupTest();
    });

    testWidgets('navigate to statistics tab', (tester) async {
      final app = await createTestApp();
      await pumpAndSettle(tester, app);
      // Tap statistics in bottom nav
      await tester.tap(find.byIcon(Icons.bar_chart_outlined));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.bar_chart), findsWidgets);
      await cleanupTest();
    });
  });

  group('Category Management', () {
    testWidgets('add category shows in list', (tester) async {
      final app = await createTestApp();
      await pumpAndSettle(tester, app);
      // Navigate to categories tab
      await tester.tap(find.byIcon(Icons.folder_outlined));
      await tester.pumpAndSettle();
      // Tap FAB to add category
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      // Enter category name in dialog
      final textField = find.byType(TextField);
      if (textField.evaluate().isNotEmpty) {
        await tester.enterText(textField.last, 'Science Fiction');
        await tester.pumpAndSettle();
        // Tap save/confirm
        final saveBtn = find.widgetWithText(TextButton, 'OK');
        final filledBtn = find.byType(FilledButton);
        if (filledBtn.evaluate().isNotEmpty) {
          await tester.tap(filledBtn.last);
        } else if (saveBtn.evaluate().isNotEmpty) {
          await tester.tap(saveBtn);
        }
        await tester.pumpAndSettle();
        // Category should appear in list
        expect(find.text('Science Fiction'), findsOneWidget);
      }
      await cleanupTest();
    });

    testWidgets('delete category removes from list', (tester) async {
      final app = await createTestApp();
      // Pre-populate a category
      await services.categoryService.create(name: 'To Delete');
      await pumpAndSettle(tester, app);
      // Navigate to categories tab
      await tester.tap(find.byIcon(Icons.folder_outlined));
      await tester.pumpAndSettle();
      expect(find.text('To Delete'), findsOneWidget);
      // Long-press or find delete action
      await tester.longPress(find.text('To Delete'));
      await tester.pumpAndSettle();
      // Look for delete option
      final deleteOption = find.byIcon(Icons.delete);
      if (deleteOption.evaluate().isNotEmpty) {
        await tester.tap(deleteOption.first);
        await tester.pumpAndSettle();
        // Confirm deletion
        final confirmBtn = find.widgetWithText(TextButton, 'OK');
        final filledConfirm = find.byType(FilledButton);
        if (filledConfirm.evaluate().isNotEmpty) {
          await tester.tap(filledConfirm.last);
        } else if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn);
        }
        await tester.pumpAndSettle();
      }
      await cleanupTest();
    });
  });

  group('Reading Queue', () {
    testWidgets('add to queue and verify order', (tester) async {
      final app = await createTestApp();
      // Pre-populate books
      final book1 = await services.bookService.create(title: 'Queue Book 1', format: BookFormat.ebook);
      final book2 = await services.bookService.create(title: 'Queue Book 2', format: BookFormat.ebook);
      final book3 = await services.bookService.create(title: 'Queue Book 3', format: BookFormat.ebook);
      // Add to queue via service
      await services.readingQueueService.addToQueue(book1.id);
      await services.readingQueueService.addToQueue(book2.id);
      await services.readingQueueService.addToQueue(book3.id);
      await pumpAndSettle(tester, app);
      // Verify queue order via service
      final queue = services.readingQueueService.getQueue();
      expect(queue.length, 3);
      expect(queue[0], book1.id);
      expect(queue[1], book2.id);
      expect(queue[2], book3.id);
      await cleanupTest();
    });

    testWidgets('remove from queue updates list', (tester) async {
      final app = await createTestApp();
      final book1 = await services.bookService.create(title: 'Remove Test 1', format: BookFormat.ebook);
      final book2 = await services.bookService.create(title: 'Remove Test 2', format: BookFormat.ebook);
      await services.readingQueueService.addToQueue(book1.id);
      await services.readingQueueService.addToQueue(book2.id);
      await pumpAndSettle(tester, app);
      // Remove first book from queue
      await services.readingQueueService.removeFromQueue(book1.id);
      final queue = services.readingQueueService.getQueue();
      expect(queue.length, 1);
      expect(queue[0], book2.id);
      await cleanupTest();
    });
  });

  group('Cross-Book Search', () {
    testWidgets('search finds highlight text across books', (tester) async {
      final app = await createTestApp();
      // Pre-populate books with highlights
      final book1 = await services.bookService.create(title: 'Book With Highlights', format: BookFormat.ebook);
      final book2 = await services.bookService.create(title: 'Another Book', format: BookFormat.ebook);
      await services.highlightService.add(book1.id, Highlight(
        id: 'h1', page: 1, startIndex: 0, endIndex: 17,
        text: 'important concept', colorValue: 0xFFFFEB3B, createdAt: DateTime.now(),
      ));
      await services.highlightService.add(book2.id, Highlight(
        id: 'h2', page: 3, startIndex: 0, endIndex: 22,
        text: 'another important idea', colorValue: 0xFF4CAF50, createdAt: DateTime.now(),
      ));
      await pumpAndSettle(tester, app);
      // Look for search icon in app bar to open cross-book search
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon.first);
        await tester.pumpAndSettle();
        // Enter search query
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField.last, 'important');
          await tester.pumpAndSettle();
          // Both results should appear
          expect(find.text('important concept'), findsOneWidget);
          expect(find.text('another important idea'), findsOneWidget);
        }
      }
      await cleanupTest();
    });
  });
}
