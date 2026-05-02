import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/features/ai_finder/data/datasources/open_ai_remote_data_source.dart';

void main() {
  group('parseStationUuidsFromOpenAiResponse', () {
    test('parses output_text JSON from Responses API', () {
      final stationUuids = parseStationUuidsFromOpenAiResponse({
        'output_text': '{"stationUuids":["station-1","station-2"]}',
      });

      expect(stationUuids, ['station-1', 'station-2']);
    });

    test('parses nested output content text', () {
      final stationUuids = parseStationUuidsFromOpenAiResponse({
        'output': [
          {
            'type': 'message',
            'content': [
              {'type': 'output_text', 'text': '{"stationUuids":["station-3"]}'},
            ],
          },
        ],
      });

      expect(stationUuids, ['station-3']);
    });

    test('parses parsed structured payloads', () {
      final stationUuids = parseStationUuidsFromOpenAiResponse({
        'output': [
          {
            'content': [
              {
                'parsed': {
                  'stationUuids': ['station-4', 'station-5'],
                },
              },
            ],
          },
        ],
      });

      expect(stationUuids, ['station-4', 'station-5']);
    });

    test('parses code fenced JSON', () {
      final stationUuids = parseStationUuidsFromOpenAiResponse({
        'output_text': '''
```json
{"stationUuids":["station-6"]}
```
''',
      });

      expect(stationUuids, ['station-6']);
    });

    test('parses a raw UUID array', () {
      final stationUuids = parseStationUuidsFromOpenAiResponse({
        'output_text': '["station-7","station-8"]',
      });

      expect(stationUuids, ['station-7', 'station-8']);
    });
  });
}
