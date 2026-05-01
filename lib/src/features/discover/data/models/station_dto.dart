import '../../domain/entities/station.dart';
import 'json_readers.dart';

class StationDto {
  const StationDto({
    required this.stationUuid,
    required this.name,
    required this.streamUrl,
    this.resolvedStreamUrl,
    this.faviconUrl,
    this.countryCode,
    this.language,
    this.tags = const <String>[],
    this.codec,
    this.bitrate,
    this.votes,
    this.clickCount,
    this.lastCheckOk = false,
  });

  factory StationDto.fromJson(Map<String, dynamic> json) {
    return StationDto(
      stationUuid: readString(json, 'stationuuid'),
      name: readString(json, 'name'),
      streamUrl: readString(json, 'url'),
      resolvedStreamUrl: readNullableString(json, 'url_resolved'),
      faviconUrl: readNullableString(json, 'favicon'),
      countryCode: readNullableString(json, 'countrycode'),
      language: readNullableString(json, 'language'),
      tags: readCommaSeparatedStrings(json, 'tags'),
      codec: readNullableString(json, 'codec'),
      bitrate: readInt(json, 'bitrate'),
      votes: readInt(json, 'votes'),
      clickCount: readInt(json, 'clickcount'),
      lastCheckOk: readBool(json, 'lastcheckok'),
    );
  }

  final String stationUuid;
  final String name;
  final String streamUrl;
  final String? resolvedStreamUrl;
  final String? faviconUrl;
  final String? countryCode;
  final String? language;
  final List<String> tags;
  final String? codec;
  final int? bitrate;
  final int? votes;
  final int? clickCount;
  final bool lastCheckOk;

  Station toDomain() {
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
      votes: votes,
      clickCount: clickCount,
      lastCheckOk: lastCheckOk,
    );
  }
}
