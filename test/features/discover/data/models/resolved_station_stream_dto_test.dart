import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/features/discover/data/models/resolved_station_stream_dto.dart';

void main() {
  test('parses click response when ok is a boolean', () {
    final dto = ResolvedStationStreamDto.fromJson(const <String, dynamic>{
      'ok': true,
      'message': 'retrieved station url',
      'stationuuid': 'station-1',
      'name': 'Demo Radio',
      'url': 'https://example.com/live.mp3',
    });

    expect(dto.ok, isTrue);
    expect(dto.stationUuid, 'station-1');
    expect(dto.url, 'https://example.com/live.mp3');
  });

  test('parses click response when ok is a string', () {
    final dto = ResolvedStationStreamDto.fromJson(const <String, dynamic>{
      'ok': 'true',
      'message': 'retrieved station url',
      'stationuuid': 'station-1',
      'name': 'Demo Radio',
      'url': 'https://example.com/live.mp3',
    });

    expect(dto.ok, isTrue);
  });
}
