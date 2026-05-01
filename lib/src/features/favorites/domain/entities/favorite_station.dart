import 'package:equatable/equatable.dart';

class FavoriteStation extends Equatable {
  const FavoriteStation({
    required this.stationUuid,
    required this.name,
    required this.streamUrl,
    required this.createdAt,
    this.resolvedStreamUrl,
    this.faviconUrl,
    this.countryCode,
    this.language,
    this.tags = const <String>[],
    this.codec,
    this.bitrate,
  });

  final String stationUuid;
  final String name;
  final String streamUrl;
  final DateTime createdAt;
  final String? resolvedStreamUrl;
  final String? faviconUrl;
  final String? countryCode;
  final String? language;
  final List<String> tags;
  final String? codec;
  final int? bitrate;

  @override
  List<Object?> get props => [
    stationUuid,
    name,
    streamUrl,
    createdAt,
    resolvedStreamUrl,
    faviconUrl,
    countryCode,
    language,
    tags,
    codec,
    bitrate,
  ];
}
