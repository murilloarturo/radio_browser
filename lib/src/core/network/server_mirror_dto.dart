class ServerMirrorDto {
  const ServerMirrorDto({required this.name});

  factory ServerMirrorDto.fromJson(Map<dynamic, dynamic> json) {
    return ServerMirrorDto(name: json['name']?.toString() ?? '');
  }

  final String name;

  Uri get baseUri => Uri.https(name);
}
