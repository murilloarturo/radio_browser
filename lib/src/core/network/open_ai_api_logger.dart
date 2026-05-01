import 'dart:developer' as developer;

void logOpenAiApi(Object? message) {
  assert(() {
    final text = '[OpenAIAPI] $message';
    developer.log(text, name: 'OpenAIAPI');
    // ignore: avoid_print
    print(text);
    return true;
  }());
}
