import 'package:radio_browser/src/features/favorites/domain/entities/favorite_station.dart';

FavoriteStation favoriteStationFixture({
  String stationUuid = 'station-1',
  String name = 'Demo Radio',
  DateTime? createdAt,
}) {
  return FavoriteStation(
    stationUuid: stationUuid,
    name: name,
    streamUrl: 'https://example.com/$stationUuid.mp3',
    resolvedStreamUrl: 'https://cdn.example.com/$stationUuid.mp3',
    faviconUrl: 'https://example.com/favicon.png',
    countryCode: 'ES',
    language: 'Spanish',
    tags: const <String>['jazz', 'news'],
    codec: 'MP3',
    bitrate: 128,
    createdAt: createdAt ?? DateTime.utc(2026, 5),
  );
}
