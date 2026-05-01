import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/features/discover/data/models/station_dto.dart';

void main() {
  test('parses a complete station payload', () {
    final dto = StationDto.fromJson(const <String, dynamic>{
      'stationuuid': 'station-1',
      'name': 'Demo Radio',
      'url': 'https://example.com/stream',
      'url_resolved': 'https://cdn.example.com/stream',
      'favicon': 'https://example.com/favicon.png',
      'countrycode': 'ES',
      'language': 'Spanish',
      'tags': ' pop, rock ,news,, ',
      'codec': 'MP3',
      'bitrate': 128,
      'votes': '42',
      'clickcount': 100,
      'lastcheckok': 1,
    });

    expect(dto.stationUuid, 'station-1');
    expect(dto.name, 'Demo Radio');
    expect(dto.streamUrl, 'https://example.com/stream');
    expect(dto.resolvedStreamUrl, 'https://cdn.example.com/stream');
    expect(dto.faviconUrl, 'https://example.com/favicon.png');
    expect(dto.countryCode, 'ES');
    expect(dto.language, 'Spanish');
    expect(dto.tags, <String>['pop', 'rock', 'news']);
    expect(dto.codec, 'MP3');
    expect(dto.bitrate, 128);
    expect(dto.votes, 42);
    expect(dto.clickCount, 100);
    expect(dto.lastCheckOk, isTrue);
  });

  test('handles missing optional fields safely', () {
    final dto = StationDto.fromJson(const <String, dynamic>{
      'stationuuid': 'station-1',
      'name': 'Demo Radio',
      'url': 'https://example.com/stream',
    });

    expect(dto.resolvedStreamUrl, isNull);
    expect(dto.faviconUrl, isNull);
    expect(dto.countryCode, isNull);
    expect(dto.language, isNull);
    expect(dto.tags, isEmpty);
    expect(dto.codec, isNull);
    expect(dto.bitrate, isNull);
    expect(dto.votes, isNull);
    expect(dto.clickCount, isNull);
    expect(dto.lastCheckOk, isFalse);
  });

  test('maps dto to domain entity', () {
    final station =
        StationDto.fromJson(const <String, dynamic>{
          'stationuuid': 'station-1',
          'name': 'Demo Radio',
          'url': 'https://example.com/stream',
          'tags': 'jazz',
          'lastcheckok': 'true',
        }).toDomain();

    expect(station.stationUuid, 'station-1');
    expect(station.name, 'Demo Radio');
    expect(station.streamUrl, 'https://example.com/stream');
    expect(station.tags, <String>['jazz']);
    expect(station.lastCheckOk, isTrue);
  });
}
