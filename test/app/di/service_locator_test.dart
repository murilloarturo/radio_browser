import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/app/di/service_locator.dart';
import 'package:radio_browser/src/features/discover/domain/repositories/station_repository.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/get_genres.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/get_stations.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/get_stations_by_uuids.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/resolve_station_stream_url.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/search_stations.dart';

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  test('registers phase one dependencies', () async {
    await configureDependencies();

    expect(getIt<StationRepository>(), isA<StationRepository>());
    expect(getIt<GetStations>(), isA<GetStations>());
    expect(getIt<SearchStations>(), isA<SearchStations>());
    expect(getIt<GetGenres>(), isA<GetGenres>());
    expect(getIt<ResolveStationStreamUrl>(), isA<ResolveStationStreamUrl>());
    expect(getIt<GetStationsByUuids>(), isA<GetStationsByUuids>());
  });
}
