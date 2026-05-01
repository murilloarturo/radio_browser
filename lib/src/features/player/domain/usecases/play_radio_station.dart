import '../../../../core/result/result.dart';
import '../../../discover/domain/entities/station.dart';
import '../../../discover/domain/usecases/resolve_station_stream_url.dart';
import '../repositories/radio_player_repository.dart';

class PlayRadioStation {
  const PlayRadioStation({
    required ResolveStationStreamUrl resolveStationStreamUrl,
    required RadioPlayerRepository radioPlayerRepository,
  }) : _resolveStationStreamUrl = resolveStationStreamUrl,
       _radioPlayerRepository = radioPlayerRepository;

  final ResolveStationStreamUrl _resolveStationStreamUrl;
  final RadioPlayerRepository _radioPlayerRepository;

  Future<Result<void>> call(Station station) async {
    final resolvedStreamResult = await _resolveStationStreamUrl(
      station.stationUuid,
    );

    return resolvedStreamResult.when(
      success:
          (resolvedStream) => _radioPlayerRepository.play(
            station: station,
            streamUrl: resolvedStream.url,
          ),
      failure: (failure) async => Failure<void>(failure),
    );
  }
}
