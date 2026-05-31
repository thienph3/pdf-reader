import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/core/utils/dialogs.dart';

void main() {
  group('showConfirmDialog', () {
    testWidgets('shows title, content, and confirm label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showConfirmDialog(context,
                title: 'Delete?',
                content: 'Are you sure?',
                confirmLabel: 'Yes'),
            child: const Text('Open'),
          );
        }),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
    });

    testWidgets('confirm returns true', (tester) async {
      bool? result;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await showConfirmDialog(context,
                  title: 'T', content: 'C', confirmLabel: 'OK');
            },
            child: const Text('Open'),
          );
        }),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('cancel returns false', (tester) async {
      bool? result;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await showConfirmDialog(context,
                  title: 'T', content: 'C', confirmLabel: 'OK');
            },
            child: const Text('Open'),
          );
        }),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      // MaterialLocalizations cancel button label
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });
  });

  group('showAppSnackBar', () {
    testWidgets('shows message', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => showAppSnackBar(context, 'Hello!'),
              child: const Text('Show'),
            );
          }),
        ),
      ));
      await tester.tap(find.text('Show'));
      await tester.pump();
      expect(find.text('Hello!'), findsOneWidget);
    });
  });
}
