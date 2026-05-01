import 'package:dio/dio.dart';

import '../config/open_ai_config.dart';
import 'open_ai_api_logger.dart';

Dio createOpenAiDio(OpenAiConfig config) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      headers: {
        Headers.contentTypeHeader: Headers.jsonContentType,
        Headers.acceptHeader: Headers.jsonContentType,
      },
    ),
  );

  assert(() {
    dio.interceptors.add(_OpenAiDebugInterceptor());
    return true;
  }());

  return dio;
}

class _OpenAiDebugInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logOpenAiApi('${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    logOpenAiApi(
      '${response.requestOptions.method} ${response.requestOptions.uri} '
      '-> ${response.statusCode}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logOpenAiApi(
      '${err.requestOptions.method} ${err.requestOptions.uri} '
      'failed: ${err.response?.statusCode ?? err.type} '
      '${_openAiErrorMessage(err.response?.data) ?? err.message ?? ''}',
    );
    handler.next(err);
  }
}

String? _openAiErrorMessage(Object? data) {
  if (data is Map<String, dynamic>) {
    final error = data['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
  }

  return null;
}
