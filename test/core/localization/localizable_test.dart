import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/core/localization/localizable.dart';

void main() {
  tearDown(Localizables.reset);

  test('resolves default dictionary values', () {
    expect(Localizable.appTitle.text, 'RadioBrowser');
    expect(Localizable.searchWithAiHint.text, 'Search with AI');
  });

  test('supports dictionary overrides', () {
    Localizables.load({Localizable.appTitle: 'Custom Radio'});

    expect(Localizable.appTitle.text, 'Custom Radio');
    expect(Localizable.discoverTab.text, 'Discover');
  });

  test('formats templated values', () {
    expect(Localizable.bitrateKbpsTemplate.format({'value': 128}), '128 kbps');
  });
}
