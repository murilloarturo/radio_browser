import '../../../favorites/domain/entities/favorite_station.dart';
import '../../domain/entities/station.dart';

extension StationFavoriteMapper on Station {
  FavoriteStation toFavoriteStation() {
    return FavoriteStation(
      stationUuid: stationUuid,
      name: name,
      streamUrl: streamUrl,
      createdAt: DateTime.now().toUtc(),
      resolvedStreamUrl: resolvedStreamUrl,
      faviconUrl: faviconUrl,
      countryCode: countryCode,
      language: language,
      tags: tags,
      codec: codec,
      bitrate: bitrate,
    );
  }
}
