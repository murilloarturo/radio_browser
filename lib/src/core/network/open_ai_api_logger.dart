import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

void logOpenAiApi(Object? message) {
  if (!kDebugMode && !kProfileMode) {
    return;
  }

  final text = '[OpenAIAPI] $message';
  developer.log(text, name: 'OpenAIAPI');

  // ignore: avoid_print
  print(text);
}
