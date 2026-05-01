sealed class RadioBrowserApiException implements Exception {
  const RadioBrowserApiException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class RadioBrowserDecodingException extends RadioBrowserApiException {
  const RadioBrowserDecodingException(super.message, {super.cause});
}
