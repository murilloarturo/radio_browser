import '../../domain/entities/station_genre.dart';
import 'json_readers.dart';

class StationGenreDto {
  const StationGenreDto({required this.name, required this.stationCount});

  factory StationGenreDto.fromJson(Map<String, dynamic> json) {
    return StationGenreDto(
      name: readString(json, 'name'),
      stationCount: readInt(json, 'stationcount') ?? 0,
    );
  }

  final String name;
  final int stationCount;

  StationGenre toDomain() {
    return StationGenre(name: name, stationCount: stationCount);
  }
}
