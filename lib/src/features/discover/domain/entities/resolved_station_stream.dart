import 'package:equatable/equatable.dart';

class ResolvedStationStream extends Equatable {
  const ResolvedStationStream({
    required this.stationUuid,
    required this.name,
    required this.url,
  });

  final String stationUuid;
  final String name;
  final String url;

  @override
  List<Object?> get props => [stationUuid, name, url];
}
