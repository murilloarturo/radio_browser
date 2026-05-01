import 'package:dio/dio.dart';

import '../config/radio_browser_config.dart';
import 'radio_browser_api_logger.dart';

Dio createRadioBrowserDio(RadioBrowserConfig config) {
  final dio = Dio(
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

  assert(() {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: logRadioBrowserApi,
      ),
    );
    return true;
  }());

  return dio;
}
