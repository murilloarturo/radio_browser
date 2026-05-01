import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_browser/src/core/result/result.dart';
import 'package:radio_browser/src/features/favorites/domain/entities/favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/add_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/get_favorite_stations.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/is_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/remove_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/toggle_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/watch_favorite_stations.dart';

import '../../../../helpers/favorite_station_fixtures.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late MockFavoritesRepository repository;
  late FavoriteStation station;

  setUpAll(() {
    registerFallbackValue(favoriteStationFixture());
  });

  setUp(() {
    repository = MockFavoritesRepository();
    station = favoriteStationFixture();
  });

  test('delegates get favorites', () async {
    when(
      () => repository.getFavoriteStations(),
    ).thenAnswer((_) async => Success(<FavoriteStation>[station]));

    final result = await GetFavoriteStations(repository)();

    expect((result as Success<List<FavoriteStation>>).value, <FavoriteStation>[
      station,
    ]);
  });

  test('delegates watch favorites', () {
    when(() => repository.watchFavoriteStations()).thenAnswer(
      (_) => Stream<Result<List<FavoriteStation>>>.value(
        Success(<FavoriteStation>[station]),
      ),
    );

    expect(
      WatchFavoriteStations(repository)(),
      emits(isA<Success<List<FavoriteStation>>>()),
    );
  });

  test('delegates add favorite', () async {
    when(
      () => repository.addFavoriteStation(any()),
    ).thenAnswer((_) async => const Success<void>(null));

    final result = await AddFavoriteStation(repository)(station);

    expect(result, isA<Success<void>>());
    verify(() => repository.addFavoriteStation(station)).called(1);
  });

  test('delegates remove favorite', () async {
    when(
      () => repository.removeFavoriteStation('station-1'),
    ).thenAnswer((_) async => const Success<void>(null));

    final result = await RemoveFavoriteStation(repository)('station-1');

    expect(result, isA<Success<void>>());
  });

  test('delegates toggle favorite', () async {
    when(
      () => repository.toggleFavoriteStation(any()),
    ).thenAnswer((_) async => const Success<bool>(true));

    final result = await ToggleFavoriteStation(repository)(station);

    expect((result as Success<bool>).value, isTrue);
  });

  test('delegates favorite status check', () async {
    when(
      () => repository.isFavoriteStation('station-1'),
    ).thenAnswer((_) async => const Success<bool>(true));

    final result = await IsFavoriteStation(repository)('station-1');

    expect((result as Success<bool>).value, isTrue);
  });
}
