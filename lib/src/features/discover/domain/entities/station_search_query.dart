import 'package:equatable/equatable.dart';

import 'station_search_order.dart';

class StationSearchQuery extends Equatable {
  const StationSearchQuery({
    this.name,
    this.tag,
    this.countryCode,
    this.language,
    this.limit = 50,
    this.offset = 0,
    this.hideBroken = true,
    this.order = StationSearchOrder.clickCount,
    this.reverse = true,
  });

  final String? name;
  final String? tag;
  final String? countryCode;
  final String? language;
  final int limit;
  final int offset;
  final bool hideBroken;
  final StationSearchOrder order;
  final bool reverse;

  Map<String, Object?> toQueryParameters() {
    return <String, Object?>{
      'name': _normalized(name),
      'tag': _normalized(tag),
      'countrycode': _normalized(countryCode)?.toUpperCase(),
      'language': _normalized(language),
      'limit': limit,
      'offset': offset,
      'hidebroken': hideBroken.toString(),
      'order': order.apiValue,
      'reverse': reverse.toString(),
    }..removeWhere((_, value) => value == null);
  }

  String? _normalized(String? value) {
    final trimmedValue = value?.trim();
    if (trimmedValue == null || trimmedValue.isEmpty) {
      return null;
    }

    return trimmedValue;
  }

  @override
  List<Object?> get props => [
    name,
    tag,
    countryCode,
    language,
    limit,
    offset,
    hideBroken,
    order,
    reverse,
  ];
}
