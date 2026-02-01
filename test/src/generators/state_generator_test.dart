import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../../bin/src/generators/state_generator.dart';

void main() {
  group('StateGenerator', () {
    late Directory tempDir;
    late Directory previousCurrent;

    setUp(() async {
      previousCurrent = Directory.current;
      tempDir = await Directory.systemTemp.createTemp('air_cli_test_state_');
      Directory.current = tempDir;

      await Directory(
        path.join(tempDir.path, 'lib', 'modules'),
      ).create(recursive: true);
      await File(
        path.join(tempDir.path, 'pubspec.yaml'),
      ).writeAsString('name: test_project');
    });

    tearDown(() async {
      Directory.current = previousCurrent;
      await tempDir.delete(recursive: true);
    });

    test('generate creates state architecture files', () async {
      final moduleName = 'cart';
      final moduleDir = Directory(
        path.join(tempDir.path, 'lib', 'modules', moduleName),
      );
      await moduleDir.create(recursive: true);

      final generator = StateGenerator();
      await generator.generate('shopping_cart', ['--module=$moduleName']);

      final statePath = path.join(moduleDir.path, 'ui', 'state');
      final stateFile = File(path.join(statePath, 'shopping_cart_state.dart'));
      final pulsesFile = File(
        path.join(statePath, 'shopping_cart_pulses.dart'),
      );
      final flowsFile = File(path.join(statePath, 'shopping_cart_flows.dart'));

      expect(await stateFile.exists(), isTrue);
      expect(await pulsesFile.exists(), isTrue);
      expect(await flowsFile.exists(), isTrue);

      final stateContent = await stateFile.readAsString();
      expect(
        stateContent,
        contains('class ShoppingCartState extends AirState'),
      );
      expect(stateContent, contains("moduleId: 'cart'"));
    });
  });
}
