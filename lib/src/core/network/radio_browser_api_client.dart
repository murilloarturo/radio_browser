import 'dart:convert';

import 'package:dio/dio.dart';

import 'radio_browser_api_exception.dart';
import 'radio_browser_server_resolver.dart';

class RadioBrowserApiClient {
  RadioBrowserApiClient({
    required Dio dio,
    required RadioBrowserServerResolver serverResolver,
  }) : _dio = dio,
       _serverResolver = serverResolver;

  final Dio _dio;
  final RadioBrowserServerResolver _serverResolver;

  Uri? _baseUri;

  Future<List<Map<String, dynamic>>> searchStations(
    Map<String, Object?> queryParameters,
  ) {
    return _getJsonList(
      '/json/stations/search',
      queryParameters: queryParameters,
    );
  }

  Future<List<Map<String, dynamic>>> getTags({
    int limit = 100,
    bool hideBroken = true,
  }) {
    return _getJsonList(
      '/json/tags',
      queryParameters: <String, Object?>{
        'limit': limit,
        'hidebroken': hideBroken.toString(),
        'order': 'stationcount',
        'reverse': 'true',
      },
    );
  }

  Future<Map<String, dynamic>> resolveStationUrl(String stationUuid) {
    return _getJsonObject('/json/url/$stationUuid');
  }

  Future<List<Map<String, dynamic>>> getStationsByUuids(
    List<String> stationUuids,
  ) {
    return _getJsonList(
      '/json/stations/byuuid',
      queryParameters: <String, Object?>{'uuids': stationUuids.join(',')},
    );
  }

  Future<List<Map<String, dynamic>>> _getJsonList(
    String path, {
    Map<String, Object?> queryParameters = const <String, Object?>{},
  }) async {
    final response = await _dio.getUri<Object?>(
      await _buildUri(path, queryParameters: queryParameters),
    );

    final data = _decode(response.data);
    if (data is! List) {
      throw RadioBrowserDecodingException('Expected a JSON list from $path.');
    }

    return data.map(_asJsonObject).toList(growable: false);
  }

  Future<Map<String, dynamic>> _getJsonObject(String path) async {
    final response = await _dio.getUri<Object?>(await _buildUri(path));
    return _asJsonObject(_decode(response.data));
  }

  Future<Uri> _buildUri(
    String path, {
    Map<String, Object?> queryParameters = const <String, Object?>{},
  }) async {
    _baseUri ??= await _serverResolver.resolveBaseUri();
    final uri = _baseUri!.resolve(path);
    return uri.replace(queryParameters: _withoutNulls(queryParameters));
  }

  Object? _decode(Object? data) {
    if (data is String) {
      try {
        return jsonDecode(data);
      } on FormatException catch (error) {
        throw RadioBrowserDecodingException(
          'Radio Browser returned invalid JSON.',
          cause: error,
        );
      }
    }

    return data;
  }

  Map<String, dynamic> _asJsonObject(Object? value) {
    if (value is! Map) {
      throw const RadioBrowserDecodingException('Expected a JSON object.');
    }

    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  Map<String, Object?> _withoutNulls(Map<String, Object?> values) {
    return Map.fromEntries(
      values.entries.where((entry) => entry.value != null),
    );
  }
}
