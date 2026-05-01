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
                  'items': {'type': 'string'},
                },
              },
            },
          },
        },
        'max_output_tokens': 1200,
      },
    );

    final outputText = _extractOutputText(response.data);
    final decoded = jsonDecode(outputText) as Map<String, dynamic>;
    final rawStationUuids = decoded['stationUuids'];
    if (rawStationUuids is! List) {
      throw const FormatException('Missing station UUID ranking.');
    }

    final allowedStationUuids =
        candidateStations.map((station) => station.stationUuid).toSet();

    return rawStationUuids
        .whereType<String>()
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

  String _extractOutputText(Map<String, dynamic>? responseData) {
    if (responseData == null) {
      throw const FormatException('Missing OpenAI response body.');
    }

    final outputText = responseData['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }

    final output = responseData['output'];
    if (output is List) {
      final buffer = StringBuffer();
      for (final outputItem in output.whereType<Map<String, dynamic>>()) {
        final content = outputItem['content'];
        if (content is List) {
          for (final contentItem in content.whereType<Map<String, dynamic>>()) {
            final text = contentItem['text'];
            if (text is String) {
              buffer.write(text);
            }
          }
        }
      }

      final resolvedText = buffer.toString().trim();
      if (resolvedText.isNotEmpty) {
        return resolvedText;
      }
    }

    throw const FormatException('Missing OpenAI output text.');
  }

  String _fileName(String filePath) {
    return filePath.split('/').last;
  }
}

const _stationRankingInstructions = '''
You are a radio station recommendation engine.
Use only the candidateStations provided by the app.
Return stationUuids ordered from best to worst for the user's request.
Do not invent station UUIDs, names, streams, genres, countries, or metadata.
If the request is vague, prefer reliable, popular stations and favorites-adjacent tags.
''';
