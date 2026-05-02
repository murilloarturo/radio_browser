import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/config/open_ai_config.dart';
import '../../../discover/domain/entities/station.dart';
import '../../../favorites/domain/entities/favorite_station.dart';

abstract interface class OpenAiRemoteDataSource {
  Future<List<String>> rankStationUuids({
    required String prompt,
    required List<Station> candidateStations,
    required List<FavoriteStation> favoriteStations,
  });

  Future<String> transcribeAudio(String filePath);
}

class DioOpenAiRemoteDataSource implements OpenAiRemoteDataSource {
  const DioOpenAiRemoteDataSource({
    required Dio dio,
    required OpenAiConfig config,
  }) : _dio = dio,
       _config = config;

  final Dio _dio;
  final OpenAiConfig _config;

  @override
  Future<List<String>> rankStationUuids({
    required String prompt,
    required List<Station> candidateStations,
    required List<FavoriteStation> favoriteStations,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/responses',
      options: _authOptions,
      data: {
        'model': _config.model,
        'instructions': _stationRankingInstructions,
        'input': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'input_text',
                'text': jsonEncode({
                  'userRequest': prompt,
                  'favorites': _favoritePayload(favoriteStations),
                  'candidateStations': _stationPayload(candidateStations),
                }),
              },
            ],
          },
        ],
        'text': {
          'format': {
            'type': 'json_schema',
            'name': 'station_ranking',
            'strict': true,
            'schema': {
              'type': 'object',
              'additionalProperties': false,
              'required': ['stationUuids'],
              'properties': {
                'stationUuids': {
                  'type': 'array',
                  'maxItems': 12,
                  'items': {'type': 'string'},
                },
              },
            },
          },
        },
        'max_output_tokens': 1200,
      },
    );

    final rawStationUuids = parseStationUuidsFromOpenAiResponse(response.data);
    final allowedStationUuids =
        candidateStations.map((station) => station.stationUuid).toSet();

    return rawStationUuids
        .map((stationUuid) => stationUuid.trim())
        .where(
          (stationUuid) =>
              stationUuid.isNotEmpty &&
              allowedStationUuids.contains(stationUuid),
        )
        .toList(growable: false);
  }

  @override
  Future<String> transcribeAudio(String filePath) async {
    final response = await _dio.post<dynamic>(
      '/audio/transcriptions',
      options: _authOptions,
      data: FormData.fromMap({
        'model': _config.transcriptionModel,
        'response_format': 'json',
        'file': await MultipartFile.fromFile(
          filePath,
          filename: _fileName(filePath),
        ),
      }),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final text = data['text'];
      if (text is String && text.trim().isNotEmpty) {
        return text.trim();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    throw const FormatException('Missing transcription text.');
  }

  Options get _authOptions {
    return Options(headers: {'Authorization': 'Bearer ${_config.apiKey}'});
  }

  List<Map<String, Object?>> _stationPayload(List<Station> stations) {
    return stations
        .map(
          (station) => {
            'stationUuid': station.stationUuid,
            'name': station.name,
            'countryCode': station.countryCode,
            'language': station.language,
            'tags': station.tags.take(8).toList(growable: false),
            'codec': station.codec,
            'bitrate': station.bitrate,
            'votes': station.votes,
            'clickCount': station.clickCount,
          },
        )
        .toList(growable: false);
  }

  List<Map<String, Object?>> _favoritePayload(List<FavoriteStation> stations) {
    return stations
        .map(
          (station) => {
            'stationUuid': station.stationUuid,
            'name': station.name,
            'countryCode': station.countryCode,
            'language': station.language,
            'tags': station.tags.take(8).toList(growable: false),
            'codec': station.codec,
            'bitrate': station.bitrate,
          },
        )
        .toList(growable: false);
  }

  String _fileName(String filePath) {
    return filePath.split('/').last;
  }
}

List<String> parseStationUuidsFromOpenAiResponse(
  Map<String, dynamic>? responseData,
) {
  final payload = _extractStructuredPayload(responseData);
  final rawStationUuids = payload['stationUuids'];
  if (rawStationUuids is! List) {
    throw const FormatException('Missing station UUID ranking.');
  }

  return rawStationUuids
      .whereType<String>()
      .map((stationUuid) => stationUuid.trim())
      .where((stationUuid) => stationUuid.isNotEmpty)
      .toList(growable: false);
}

Map<String, dynamic> _extractStructuredPayload(
  Map<String, dynamic>? responseData,
) {
  if (responseData == null) {
    throw const FormatException('Missing OpenAI response body.');
  }

  final directPayload = _tryParsePayload(responseData);
  if (directPayload != null) {
    return directPayload;
  }

  final outputTextPayload = _tryParsePayload(responseData['output_text']);
  if (outputTextPayload != null) {
    return outputTextPayload;
  }

  final output = responseData['output'];
  if (output is List) {
    final textBuffer = StringBuffer();
    for (final outputItem in output) {
      final outputPayload = _tryParsePayload(outputItem);
      if (outputPayload != null) {
        return outputPayload;
      }

      final outputMap = _asStringKeyedMap(outputItem);
      final content = outputMap?['content'];
      if (content is! List) {
        continue;
      }

      for (final contentItem in content) {
        final contentPayload = _tryParsePayload(contentItem);
        if (contentPayload != null) {
          return contentPayload;
        }

        final contentMap = _asStringKeyedMap(contentItem);
        if (contentMap == null) {
          continue;
        }

        for (final key in const ['parsed', 'json', 'output_text', 'text']) {
          final payload = _tryParsePayload(contentMap[key]);
          if (payload != null) {
            return payload;
          }
        }

        final text = contentMap['text'];
        if (text is String) {
          textBuffer.write(text);
        }
      }
    }

    final combinedPayload = _tryParsePayload(textBuffer.toString());
    if (combinedPayload != null) {
      return combinedPayload;
    }
  }

  throw const FormatException('Missing OpenAI station ranking.');
}

Map<String, dynamic>? _tryParsePayload(Object? value) {
  final valueMap = _asStringKeyedMap(value);
  if (valueMap != null) {
    if (valueMap.containsKey('stationUuids')) {
      return valueMap;
    }

    for (final key in const ['parsed', 'json']) {
      final nestedPayload = _tryParsePayload(valueMap[key]);
      if (nestedPayload != null) {
        return nestedPayload;
      }
    }
  }

  if (value is! String || value.trim().isEmpty) {
    return null;
  }

  final decoded = _tryDecodeJson(value);
  if (decoded is List) {
    return {'stationUuids': decoded};
  }

  return _asStringKeyedMap(decoded);
}

Object? _tryDecodeJson(String text) {
  for (final candidate in _jsonCandidates(text)) {
    try {
      return jsonDecode(candidate);
    } on FormatException {
      continue;
    }
  }

  return null;
}

List<String> _jsonCandidates(String text) {
  final trimmed = text.trim();
  final withoutFence = _stripCodeFence(trimmed);
  final candidates = <String>[trimmed, withoutFence];

  final objectStart = withoutFence.indexOf('{');
  final objectEnd = withoutFence.lastIndexOf('}');
  if (objectStart != -1 && objectEnd > objectStart) {
    candidates.add(withoutFence.substring(objectStart, objectEnd + 1));
  }

  final arrayStart = withoutFence.indexOf('[');
  final arrayEnd = withoutFence.lastIndexOf(']');
  if (arrayStart != -1 && arrayEnd > arrayStart) {
    candidates.add(withoutFence.substring(arrayStart, arrayEnd + 1));
  }

  return candidates.toSet().toList(growable: false);
}

String _stripCodeFence(String text) {
  if (!text.startsWith('```')) {
    return text;
  }

  final lines = text.split('\n');
  if (lines.length < 2) {
    return text;
  }

  final bodyLines = lines.sublist(1);
  if (bodyLines.isNotEmpty && bodyLines.last.trim() == '```') {
    bodyLines.removeLast();
  }

  return bodyLines.join('\n').trim();
}

Map<String, dynamic>? _asStringKeyedMap(Object? value) {
  if (value is! Map) {
    return null;
  }

  return value.map<String, dynamic>(
    (key, value) => MapEntry(key.toString(), value),
  );
}

const _stationRankingInstructions = '''
You are a radio station recommendation engine.
Use only the candidateStations provided by the app.
Return stationUuids ordered from best to worst for the user's request.
Return at most 12 stationUuids; the app will keep the remaining candidates.
Do not invent station UUIDs, names, streams, genres, countries, or metadata.
If the request is vague, prefer reliable, popular stations and favorites-adjacent tags.
''';
