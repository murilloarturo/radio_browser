import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/network/radio_browser_api_exception.dart';

AppFailure mapRadioBrowserFailure(Object error) {
  if (error is DioException) {
    return _mapDioException(error);
  }

  if (error is RadioBrowserDecodingException || error is FormatException) {
    return DecodingFailure('Unable to read the Radio Browser response.', error);
  }

  if (error is TypeError) {
    return DecodingFailure(
      'Radio Browser returned data in an unexpected shape.',
      error,
    );
  }

  return UnknownFailure('Radio Browser request failed.', error);
}

AppFailure _mapDioException(DioException error) {
  final statusCode = error.response?.statusCode;

  return switch (error.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => NetworkFailure(
      'Unable to connect to Radio Browser.',
      error,
    ),
    DioExceptionType.badResponse => ServerFailure(
      'Radio Browser returned an unsuccessful response.',
      statusCode: statusCode,
      cause: error,
    ),
    DioExceptionType.cancel => NetworkFailure(
      'Radio Browser request was cancelled.',
      error,
    ),
    DioExceptionType.badCertificate => NetworkFailure(
      'Radio Browser certificate could not be trusted.',
      error,
    ),
    DioExceptionType.unknown =>
      statusCode == null
          ? NetworkFailure('Unable to connect to Radio Browser.', error)
          : ServerFailure(
            'Radio Browser returned an unsuccessful response.',
            statusCode: statusCode,
            cause: error,
          ),
  };
}
