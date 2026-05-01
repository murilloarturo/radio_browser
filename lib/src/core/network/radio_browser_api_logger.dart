import 'dart:developer' as developer;

void logRadioBrowserApi(Object? message) {
  assert(() {
    final text = '[RadioBrowserAPI] $message';
    developer.log(text, name: 'RadioBrowserAPI');
    // ignore: avoid_print
    print(text);
    return true;
  }());
}
