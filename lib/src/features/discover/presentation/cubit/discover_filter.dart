import 'package:equatable/equatable.dart';

import '../../domain/entities/station_search_query.dart';

class DiscoverFilter extends Equatable {
  const DiscoverFilter._({required this.label, required this.query});

  final String label;
  final StationSearchQuery query;

  static const popular = DiscoverFilter._(
    label: 'Popular',
    query: StationSearchQuery(),
  );

  static const spain = DiscoverFilter._(
    label: 'Spain',
    query: StationSearchQuery(countryCode: 'ES'),
  );

  static const jazz = DiscoverFilter._(
    label: 'Jazz',
    query: StationSearchQuery(tag: 'jazz'),
  );

  static const news = DiscoverFilter._(
    label: 'News',
    query: StationSearchQuery(tag: 'news'),
  );

  static const rock = DiscoverFilter._(
    label: 'Rock',
    query: StationSearchQuery(tag: 'rock'),
  );

  static const defaults = <DiscoverFilter>[popular, spain, jazz, news, rock];

  @override
  List<Object?> get props => [label, query];
}
