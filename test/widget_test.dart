import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/app/app.dart';

void main() {
  testWidgets('renders the scaffolded app shell', (tester) async {
    await tester.pumpWidget(
      const RadioBrowserApp(home: Scaffold(body: Text('RadioBrowser'))),
    );

    expect(find.text('RadioBrowser'), findsOneWidget);
  });

  testWidgets('uses system theme with light and dark themes configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      const RadioBrowserApp(home: Scaffold(body: Text('RadioBrowser'))),
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.themeMode, ThemeMode.system);
    expect(app.theme, isNotNull);
    expect(app.darkTheme, isNotNull);
  });
}
