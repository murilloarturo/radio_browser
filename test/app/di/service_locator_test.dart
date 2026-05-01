import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/app/di/service_locator.dart';
import 'package:radio_browser/src/features/discover/domain/repositories/station_repository.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/get_genres.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/get_stations.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/get_stations_by_uuids.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/resolve_station_stream_url.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/search_stations.dart';
import 'package:radio_browser/src/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/add_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/get_favorite_stations.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/is_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/remove_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/toggle_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/watch_favorite_stations.dart';

import '../../helpers/hive_test_box.dart';

void main() {
  late HiveTestBox hive;

  setUp(() async {
    hive = await openHiveTestBox();
  });

  tearDown(() async {
    await getIt.reset();
    await hive.dispose();
  });

  test('registers app dependencies', () async {
    await configureDependencies(favoriteStationsBox: hive.favoriteStationsBox);

    expect(getIt<StationRepository>(), isA<StationRepository>());
    expect(getIt<GetStations>(), isA<GetStations>());
    expect(getIt<SearchStations>(), isA<SearchStations>());
    expect(getIt<GetGenres>(), isA<GetGenres>());
    expect(getIt<ResolveStationStreamUrl>(), isA<ResolveStationStreamUrl>());
    expect(getIt<GetStationsByUuids>(), isA<GetStationsByUuids>());

    expect(getIt<FavoritesRepository>(), isA<FavoritesRepository>());
    expect(getIt<GetFavoriteStations>(), isA<GetFavoriteStations>());
    expect(getIt<WatchFavoriteStations>(), isA<WatchFavoriteStations>());
    expect(getIt<AddFavoriteStation>(), isA<AddFavoriteStation>());
    expect(getIt<RemoveFavoriteStation>(), isA<RemoveFavoriteStation>());
    expect(getIt<ToggleFavoriteStation>(), isA<ToggleFavoriteStation>());
    expect(getIt<IsFavoriteStation>(), isA<IsFavoriteStation>());
  });
}
