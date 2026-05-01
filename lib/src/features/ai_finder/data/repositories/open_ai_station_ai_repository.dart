import '../../../../core/config/open_ai_config.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../core/network/open_ai_api_logger.dart';
import '../../../../core/result/result.dart';
import '../../../discover/domain/entities/station.dart';
import '../../../favorites/domain/entities/favorite_station.dart';
import '../../domain/repositories/station_ai_repository.dart';
import '../datasources/open_ai_remote_data_source.dart';
import 'open_ai_failure_mapper.dart';

class OpenAiStationAiRepository implements StationAiRepository {
  const OpenAiStationAiRepository({
    required OpenAiConfig config,
    required OpenAiRemoteDataSource remoteDataSource,
  }) : _config = config,
       _remoteDataSource = remoteDataSource;

  final OpenAiConfig _config;
  final OpenAiRemoteDataSource _remoteDataSource;

  @override
  bool get isEnabled => _config.isEnabled;

  @override
  Future<Result<List<String>>> rankStationUuids({
    required String prompt,
    required List<Station> candidateStations,
    required List<FavoriteStation> favoriteStations,
  }) {
    return _guard(
      () => _remoteDataSource.rankStationUuids(
        prompt: prompt,
        candidateStations: candidateStations,
        favoriteStations: favoriteStations,
      ),
    );
  }

  @override
  Future<Result<String>> transcribeAudio(String filePath) {
    return _guard(() => _remoteDataSource.transcribeAudio(filePath));
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    if (!isEnabled) {
      logOpenAiApi('OpenAI disabled: OPENAI_API_KEY was not provided.');
      return Failure<T>(
        const AiUnavailableFailure(
          'OpenAI is disabled. Run with --dart-define=OPENAI_API_KEY=your_key.',
        ),
      );
    }

    try {
      return Success<T>(await action());
    } on Object catch (error) {
      final failure = mapOpenAiFailure(error);
      logOpenAiApi('${failure.runtimeType}: ${failure.message}');
      return Failure<T>(failure);
    }
  }
}
