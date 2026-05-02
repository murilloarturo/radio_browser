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
          {'type': 'reasoning', 'summary': <Object?>[]},
          {
            'type': 'message',
            'status': 'completed',
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

    test('parses alternate station UUID keys', () {
      final stationUuids = parseStationUuidsFromOpenAiResponse({
        'output': [
          {
            'content': [
              {'text': '{"station_uuids":["station-9","station-10"]}'},
            ],
          },
        ],
      });

      expect(stationUuids, ['station-9', 'station-10']);
    });

    test('parses station object arrays', () {
      final stationUuids = parseStationUuidsFromOpenAiResponse({
        'output_text':
            '{"stations":[{"stationUuid":"station-11"},{"id":"station-12"}]}',
      });

      expect(stationUuids, ['station-11', 'station-12']);
    });

    test('reports incomplete responses clearly', () {
      expect(
        () => parseStationUuidsFromOpenAiResponse({
          'status': 'incomplete',
          'incomplete_details': {'reason': 'max_output_tokens'},
          'output': [
            {'type': 'reasoning', 'summary': <Object?>[]},
          ],
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('max_output_tokens'),
          ),
        ),
      );
    });

    test('summarizes response shape without full payload text', () {
      final summary = summarizeOpenAiResponse({
        'status': 'completed',
        'output': [
          {
            'type': 'message',
            'status': 'completed',
            'content': [
              {'type': 'output_text', 'text': '{"unexpected":true}'},
            ],
          },
        ],
      });

      expect(summary, contains('status=completed'));
      expect(summary, contains('type=message'));
      expect(summary, contains('textLength=19'));
      expect(summary, isNot(contains('unexpected')));
    });
  });
}
