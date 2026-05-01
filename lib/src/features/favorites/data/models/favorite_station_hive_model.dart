import 'package:hive/hive.dart';

import '../../domain/entities/favorite_station.dart';

class FavoriteStationHiveModel {
  const FavoriteStationHiveModel({
    required this.stationUuid,
    required this.name,
    required this.streamUrl,
    required this.createdAt,
    this.resolvedStreamUrl,
    this.faviconUrl,
    this.countryCode,
    this.language,
    this.tags = const <String>[],
    this.codec,
    this.bitrate,
  });

  factory FavoriteStationHiveModel.fromDomain(FavoriteStation station) {
    return FavoriteStationHiveModel(
      stationUuid: station.stationUuid,
      name: station.name,
      streamUrl: station.streamUrl,
      createdAt: station.createdAt,
      resolvedStreamUrl: station.resolvedStreamUrl,
      faviconUrl: station.faviconUrl,
      countryCode: station.countryCode,
      language: station.language,
      tags: station.tags,
      codec: station.codec,
      bitrate: station.bitrate,
    );
  }

  final String stationUuid;
  final String name;
  final String streamUrl;
  final DateTime createdAt;
  final String? resolvedStreamUrl;
  final String? faviconUrl;
  final String? countryCode;
  final String? language;
  final List<String> tags;
  final String? codec;
  final int? bitrate;

  FavoriteStation toDomain() {
    return FavoriteStation(
      stationUuid: stationUuid,
      name: name,
      streamUrl: streamUrl,
      createdAt: createdAt,
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

class FavoriteStationHiveModelAdapter
    extends TypeAdapter<FavoriteStationHiveModel> {
  @override
  final int typeId = 1;

  @override
  FavoriteStationHiveModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, Object?>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return FavoriteStationHiveModel(
      stationUuid: fields[0]! as String,
      name: fields[1]! as String,
      streamUrl: fields[2]! as String,
      resolvedStreamUrl: fields[3] as String?,
      faviconUrl: fields[4] as String?,
      countryCode: fields[5] as String?,
      language: fields[6] as String?,
      tags: (fields[7] as List?)?.cast<String>() ?? const <String>[],
      codec: fields[8] as String?,
      bitrate: fields[9] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[10]! as int),
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteStationHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.stationUuid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.streamUrl)
      ..writeByte(3)
      ..write(obj.resolvedStreamUrl)
      ..writeByte(4)
      ..write(obj.faviconUrl)
      ..writeByte(5)
      ..write(obj.countryCode)
      ..writeByte(6)
      ..write(obj.language)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.codec)
      ..writeByte(9)
      ..write(obj.bitrate)
      ..writeByte(10)
      ..write(obj.createdAt.millisecondsSinceEpoch);
  }
}
