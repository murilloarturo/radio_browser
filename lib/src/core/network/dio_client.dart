import 'package:dio/dio.dart';

import '../config/radio_browser_config.dart';

Dio createRadioBrowserDio(RadioBrowserConfig config) {
  return Dio(
    BaseOptions(
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      responseType: ResponseType.json,
      headers: <String, Object?>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': config.userAgent,
      },
    ),
  );
}
