import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/features/reader/widgets/ocr_overlay.dart';
import 'package:pdf_reader/core/l10n/app_strings.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [AppStringsDelegate()],
    locale: const Locale('en'),
    home: Scaffold(body: Stack(children: [child])),
  );
}

void main() {
  group('PdfOcrOverlay', () {
    testWidgets('shows progress when batch running', (tester) async {
      await tester.pumpWidget(_wrap(PdfOcrOverlay(
        ocrInProgress: false,
        ocrBatchRunning: true,
        ocrBatchDone: 5,
        ocrBatchTotal: 10,
        onCancelBatch: () {},
      )));
      await tester.pump();
      expect(find.textContaining('5'), findsOneWidget);
      expect(find.textContaining('10'), findsOneWidget);
    });

    testWidgets('hidden when not running', (tester) async {
      await tester.pumpWidget(_wrap(PdfOcrOverlay(
        ocrInProgress: false,
        ocrBatchRunning: false,
        ocrBatchDone: 0,
        ocrBatchTotal: 0,
        onCancelBatch: () {},
      )));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('cancel button calls callback', (tester) async {
      var cancelled = false;
      await tester.pumpWidget(_wrap(PdfOcrOverlay(
        ocrInProgress: false,
        ocrBatchRunning: true,
        ocrBatchDone: 2,
        ocrBatchTotal: 8,
        onCancelBatch: () => cancelled = true,
      )));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      expect(cancelled, isTrue);
    });

    testWidgets('shows processing text when ocrInProgress', (tester) async {
      await tester.pumpWidget(_wrap(PdfOcrOverlay(
        ocrInProgress: true,
        ocrBatchRunning: false,
        ocrBatchDone: 0,
        ocrBatchTotal: 0,
        onCancelBatch: () {},
      )));
      await tester.pump();
      expect(find.textContaining('Recognizing'), findsOneWidget);
    });
  });
}
