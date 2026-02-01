import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../../bin/src/templates/starter_template.dart';

void main() {
  group('StarterTemplate', () {
    late Directory tempDir;
    late Directory previousCurrent;

    setUp(() async {
      previousCurrent = Directory.current;
      tempDir = await Directory.systemTemp.createTemp('air_cli_test_starter_');
      Directory.current = tempDir;
    });

    tearDown(() async {
      Directory.current = previousCurrent;
      await tempDir.delete(recursive: true);
    });

    test('apply creates full structure with auth', () async {
      final projectName = 'my_starter_app';
      final projectDir = Directory(path.join(tempDir.path, projectName));

      final template = StarterTemplate();
      await template.apply(projectName, 'com.example');

      final libPath = path.join(projectDir.path, 'lib');

      // Check auth module
      final authPath = path.join(libPath, 'modules', 'auth');
      expect(await Directory(authPath).exists(), isTrue);
      expect(
        await File(path.join(authPath, 'auth_module.dart')).exists(),
        isTrue,
      );
      expect(
        await File(
          path.join(authPath, 'services', 'auth_service.dart'),
        ).exists(),
        isTrue,
      );

      // Check home module updated
      final homePath = path.join(libPath, 'modules', 'home');
      expect(await Directory(homePath).exists(), isTrue);

      // Check main.dart includes auth
      final mainContent = await File(
        path.join(libPath, 'main.dart'),
      ).readAsString();
      expect(mainContent, contains('AuthModule'));
      expect(mainContent, contains('HomeModule'));
    });
  });
}
