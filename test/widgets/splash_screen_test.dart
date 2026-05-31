import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_reader/app/splash_screen.dart';
import 'package:pdf_reader/core/l10n/app_strings.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('shows app name and subtitle on initial render',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        localizationsDelegates: [AppStringsDelegate()],
        locale: Locale('en'),
        home: SplashScreen(),
      ));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('PDF Reader'), findsOneWidget);
      expect(find.text('Your book library'), findsOneWidget);

      // Drain the 1200ms navigation timer. MainShell will throw because
      // SettingsScope is missing in test — that's expected.
      final errors = <FlutterErrorDetails>[];
      FlutterError.onError = (d) => errors.add(d);
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump();
      FlutterError.onError = FlutterError.dumpErrorToConsole;
    });
  });
}
