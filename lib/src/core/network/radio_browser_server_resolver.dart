import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';

import '../config/radio_browser_config.dart';
import 'server_mirror_dto.dart';

typedef InternetAddressLookup =
    Future<List<InternetAddress>> Function(String host);

class RadioBrowserServerResolver {
  RadioBrowserServerResolver({
    required RadioBrowserConfig config,
    required Dio dio,
    InternetAddressLookup lookup = InternetAddress.lookup,
    Random? random,
  }) : _config = config,
       _dio = dio,
       _lookup = lookup,
       _random = random ?? Random();

  final RadioBrowserConfig _config;
  final Dio _dio;
  final InternetAddressLookup _lookup;
  final Random _random;

  Future<Uri> resolveBaseUri() async {
    final dnsServers = await _resolveFromDns();
    if (dnsServers.isNotEmpty) {
      return _pick(dnsServers);
    }

    final apiServers = await _resolveFromServersEndpoint();
    if (apiServers.isNotEmpty) {
      return _pick(apiServers);
    }

    return Uri.parse(_config.fallbackBaseUrl);
  }

  Future<List<Uri>> _resolveFromDns() async {
    try {
      final addresses = await _lookup(_config.mirrorLookupHost);
      final hosts = <String>{};

      for (final address in addresses) {
        try {
          final reversedAddress = await address.reverse();
          final host = reversedAddress.host.trim();
          if (host.endsWith('api.radio-browser.info')) {
            hosts.add(host);
          }
        } on SocketException {
          // Skip addresses that cannot be reverse-resolved.
        }
      }

      return hosts.map((host) => Uri.https(host)).toList(growable: false);
    } on SocketException {
      return const <Uri>[];
    }
  }

  Future<List<Uri>> _resolveFromServersEndpoint() async {
    try {
      final endpoint = Uri.parse(
        _config.fallbackBaseUrl,
      ).resolve('/json/servers');
      final response = await _dio.getUri<Object?>(endpoint);
      final data = response.data;
      if (data is! List) {
        return const <Uri>[];
      }

      return data
          .whereType<Map<dynamic, dynamic>>()
          .map((json) => ServerMirrorDto.fromJson(json).baseUri)
          .toSet()
          .toList(growable: false);
    } on Object {
      return const <Uri>[];
    }
  }

  Uri _pick(List<Uri> servers) {
    final sortedServers = [...servers]
      ..sort((left, right) => left.toString().compareTo(right.toString()));
    return sortedServers[_random.nextInt(sortedServers.length)];
  }
}
