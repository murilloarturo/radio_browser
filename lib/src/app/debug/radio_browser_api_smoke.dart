import '../../core/result/result.dart';
import '../../features/discover/domain/usecases/get_stations.dart';
import '../di/service_locator.dart';

const _isRadioBrowserApiSmokeEnabled = bool.fromEnvironment(
  'RADIO_BROWSER_API_SMOKE',
);

void runRadioBrowserApiSmokeIfEnabled() {
  assert(() {
    if (_isRadioBrowserApiSmokeEnabled) {
      _runRadioBrowserApiSmoke();
    }
    return true;
  }());
}

Future<void> _runRadioBrowserApiSmoke() async {
  final result = await getIt<GetStations>()();

  switch (result) {
    case Success(value: final stations):
      // ignore: avoid_print
      print('[RadioBrowserAPI] Smoke OK: loaded ${stations.length} stations');
      if (stations.isNotEmpty) {
        final firstStation = stations.first;
        // ignore: avoid_print
        print(
          '[RadioBrowserAPI] First station: '
          '${firstStation.name} (${firstStation.stationUuid})',
        );
      }
    case Failure(failure: final failure):
      // ignore: avoid_print
      print(
        '[RadioBrowserAPI] Smoke failed: '
        '${failure.runtimeType} - ${failure.message}',
      );
  }
}
