import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/features/discover/data/models/station_genre_dto.dart';

void main() {
  test('maps tag payload to station genre', () {
    final genre =
        StationGenreDto.fromJson(const <String, dynamic>{
          'name': 'jazz',
          'stationcount': '123',
        }).toDomain();

    expect(genre.name, 'jazz');
    expect(genre.stationCount, 123);
  });
}
