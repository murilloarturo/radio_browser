import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/features/discover/domain/entities/station_search_order.dart';
import 'package:radio_browser/src/features/discover/domain/entities/station_search_query.dart';

void main() {
  test('serializes default query parameters for Radio Browser search', () {
    expect(const StationSearchQuery().toQueryParameters(), <String, Object?>{
      'limit': 50,
      'offset': 0,
      'hidebroken': 'true',
      'order': 'clickcount',
      'reverse': 'true',
    });
  });

  test('serializes optional filters and trims blank values', () {
    final params =
        const StationSearchQuery(
          name: '  jazz fm ',
          tag: ' jazz ',
          countryCode: 'es',
          language: ' spanish ',
          limit: 25,
          offset: 50,
          hideBroken: false,
          order: StationSearchOrder.votes,
          reverse: false,
        ).toQueryParameters();

    expect(params, <String, Object?>{
      'name': 'jazz fm',
      'tag': 'jazz',
      'countrycode': 'ES',
      'language': 'spanish',
      'limit': 25,
      'offset': 50,
      'hidebroken': 'false',
      'order': 'votes',
      'reverse': 'false',
    });
  });
}
