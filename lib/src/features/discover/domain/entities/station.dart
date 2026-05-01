import 'package:equatable/equatable.dart';

class Station extends Equatable {
  const Station({
    required this.stationUuid,
    required this.name,
    required this.streamUrl,
    this.resolvedStreamUrl,
    this.faviconUrl,
    this.countryCode,
    this.language,
    this.tags = const <String>[],
    this.codec,
    this.bitrate,
    this.votes,
    this.clickCount,
    this.lastCheckOk = false,
  });

  final String stationUuid;
  final String name;
  final String streamUrl;
  final String? resolvedStreamUrl;
  final String? faviconUrl;
  final String? countryCode;
  final String? language;
  final List<String> tags;
  final String? codec;
  final int? bitrate;
  final int? votes;
  final int? clickCount;
  final bool lastCheckOk;

  @override
  List<Object?> get props => [
    stationUuid,
    name,
    streamUrl,
    resolvedStreamUrl,
    faviconUrl,
    countryCode,
    language,
    tags,
    codec,
    bitrate,
    votes,
    clickCount,
    lastCheckOk,
  ];
}
