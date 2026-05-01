import 'package:equatable/equatable.dart';

import '../../../../core/localization/localizable.dart';
import '../../domain/entities/station_search_query.dart';

class DiscoverFilter extends Equatable {
  const DiscoverFilter._({required this.labelKey, required this.query});

  final Localizable labelKey;
  final StationSearchQuery query;

  static const popular = DiscoverFilter._(
    labelKey: Localizable.discoverFilterPopular,
    query: StationSearchQuery(),
  );

  static const spain = DiscoverFilter._(
    labelKey: Localizable.discoverFilterSpain,
    query: StationSearchQuery(countryCode: 'ES'),
  );

  static const jazz = DiscoverFilter._(
    labelKey: Localizable.discoverFilterJazz,
    query: StationSearchQuery(tag: 'jazz'),
  );

  static const news = DiscoverFilter._(
    labelKey: Localizable.discoverFilterNews,
    query: StationSearchQuery(tag: 'news'),
  );

  static const rock = DiscoverFilter._(
    labelKey: Localizable.discoverFilterRock,
    query: StationSearchQuery(tag: 'rock'),
  );

  static const defaults = <DiscoverFilter>[popular, spain, jazz, news, rock];

  @override
  List<Object?> get props => [labelKey, query];
}
