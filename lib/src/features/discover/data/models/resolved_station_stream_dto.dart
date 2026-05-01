import '../../domain/entities/resolved_station_stream.dart';
import 'json_readers.dart';

class ResolvedStationStreamDto {
  const ResolvedStationStreamDto({
    required this.ok,
    required this.message,
    required this.stationUuid,
    required this.name,
    required this.url,
  });

  factory ResolvedStationStreamDto.fromJson(Map<String, dynamic> json) {
    return ResolvedStationStreamDto(
      ok: readBool(json, 'ok'),
      message: readString(json, 'message'),
      stationUuid: readString(json, 'stationuuid'),
      name: readString(json, 'name'),
      url: readString(json, 'url'),
    );
  }

  final bool ok;
  final String message;
  final String stationUuid;
  final String name;
  final String url;

  ResolvedStationStream toDomain() {
    return ResolvedStationStream(
      stationUuid: stationUuid,
      name: name,
      url: url,
    );
  }
}
