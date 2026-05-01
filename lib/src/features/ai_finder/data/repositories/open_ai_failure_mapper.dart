import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';

AppFailure mapOpenAiFailure(Object error) {
  if (error is FormatException || error is TypeError) {
    return DecodingFailure('Unable to read the OpenAI response.', error);
  }

  if (error is DioException) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return NetworkFailure('Unable to connect to OpenAI.', error);
    }

    final statusCode = error.response?.statusCode;
    return ServerFailure(
      _openAiErrorMessage(error.response?.data) ?? 'OpenAI request failed.',
      statusCode: statusCode,
      cause: error,
    );
  }

  return UnknownFailure('OpenAI request failed.', error);
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

  if (data is String && data.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      return _openAiErrorMessage(decoded);
    } on Object {
      return data.trim();
    }
  }

  return null;
}
