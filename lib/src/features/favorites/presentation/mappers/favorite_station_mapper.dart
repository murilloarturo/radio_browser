import '../../../discover/domain/entities/station.dart';
import '../../domain/entities/favorite_station.dart';

extension FavoriteStationPresentationMapper on FavoriteStation {
  Station toStation() {
    return Station(
      stationUuid: stationUuid,
      name: name,
      streamUrl: streamUrl,
      resolvedStreamUrl: resolvedStreamUrl,
      faviconUrl: faviconUrl,
      countryCode: countryCode,
      language: language,
      tags: tags,
      codec: codec,
      bitrate: bitrate,
      lastCheckOk: true,
    );
  }
}
