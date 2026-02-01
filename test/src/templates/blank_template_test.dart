import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../../bin/src/templates/blank_template.dart';

void main() {
  group('BlankTemplate', () {
    late Directory tempDir;
    late Directory previousCurrent;

    setUp(() async {
      previousCurrent = Directory.current;
      tempDir = await Directory.systemTemp.createTemp('air_cli_test_blank_');
      Directory.current = tempDir;
    });

    tearDown(() async {
      Directory.current = previousCurrent;
      await tempDir.delete(recursive: true);
    });

    test('apply creates minimal structure', () async {
      final projectName = 'my_app';
      final projectDir = Directory(path.join(tempDir.path, projectName));

      final template = BlankTemplate();
      await template.apply(projectName, 'com.example');

      final libPath = path.join(projectDir.path, 'lib');
      expect(await File(path.join(libPath, 'main.dart')).exists(), isTrue);
      expect(await File(path.join(libPath, 'app.dart')).exists(), isTrue);
      expect(
        await File(
          path.join(libPath, 'modules', 'home', 'home_module.dart'),
        ).exists(),
        isTrue,
      );

      final mainContent = await File(
        path.join(libPath, 'main.dart'),
      ).readAsString();
      expect(mainContent, contains('HomeModule'));
    });
  });
}
