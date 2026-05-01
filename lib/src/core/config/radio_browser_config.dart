class RadioBrowserConfig {
  const RadioBrowserConfig({
    required this.appName,
    required this.appVersion,
    required this.fallbackBaseUrl,
    required this.mirrorLookupHost,
    required this.connectTimeout,
    required this.receiveTimeout,
  });

  static const production = RadioBrowserConfig(
    appName: 'RadioBrowser',
    appVersion: '1.0',
    fallbackBaseUrl: 'https://all.api.radio-browser.info',
    mirrorLookupHost: 'all.api.radio-browser.info',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 15),
  );

  final String appName;
  final String appVersion;
  final String fallbackBaseUrl;
  final String mirrorLookupHost;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  String get userAgent => '$appName/$appVersion';
}
