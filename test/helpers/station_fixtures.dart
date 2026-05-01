import 'package:radio_browser/src/features/discover/domain/entities/station.dart';

Station stationFixture({
  String stationUuid = 'station-1',
  String name = 'Radio Paradise',
}) {
  return Station(
    stationUuid: stationUuid,
    name: name,
    streamUrl: 'https://example.com/$stationUuid.mp3',
    resolvedStreamUrl: 'https://cdn.example.com/$stationUuid.mp3',
    faviconUrl: 'https://example.com/favicon.png',
    countryCode: 'US',
    language: 'English',
    tags: const <String>['eclectic', 'rock', 'chill'],
    codec: 'AAC',
    bitrate: 128,
    votes: 100,
    clickCount: 25,
    lastCheckOk: true,
  );
}
