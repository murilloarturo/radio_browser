import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/app/app.dart';

void main() {
  testWidgets('renders the scaffolded app shell', (tester) async {
    await tester.pumpWidget(const RadioBrowserApp());

    expect(find.text('RadioBrowser'), findsOneWidget);
  });
}
