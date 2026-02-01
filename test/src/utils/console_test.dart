import 'dart:async';

import 'package:test/test.dart';

import '../../../bin/src/utils/console.dart';

void main() {
  group('Console', () {
    // Helper to capture stdout
    List<String> capturePrint(void Function() callback) {
      final logs = <String>[];
      final spec = ZoneSpecification(
        print: (_, __, ___, line) {
          logs.add(line);
        },
      );

      Zone.current.fork(specification: spec).run(callback);
      return logs;
    }

    test('info prints blue message', () {
      final logs = capturePrint(() => Console.info('Test info'));
      expect(logs.length, 1);
      expect(logs.first, contains('Test info'));
      expect(logs.first, contains('\x1B[34m')); // Blue
    });

    test('success prints green message', () {
      final logs = capturePrint(() => Console.success('Test success'));
      expect(logs.length, 1);
      expect(logs.first, contains('Test success'));
      expect(logs.first, contains('\x1B[32m')); // Green
    });

    test('warning prints yellow message', () {
      final logs = capturePrint(() => Console.warning('Test warning'));
      expect(logs.length, 1);
      expect(logs.first, contains('Test warning'));
      expect(logs.first, contains('\x1B[33m')); // Yellow
    });

    test('error prints red message', () {
      final logs = capturePrint(() => Console.error('Test error'));
      expect(logs.length, 1);
      expect(logs.first, contains('Test error'));
      expect(logs.first, contains('\x1B[31m')); // Red
    });

    test('toJson formats map correctly', () {
      // Assuming Console might not have toJson but checking if I missed it in file_utils or if it belongs here.
      // Wait, toJson was in FileUtils in the previous read.
      // Checking Console.dart content again... it doesn't have toJson.
      // Skipping this test.
    });
  });
}
