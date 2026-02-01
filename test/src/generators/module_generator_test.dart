import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../../bin/src/generators/module_generator.dart';

void main() {
  group('ModuleGenerator', () {
    late Directory tempDir;
    late Directory previousCurrent;

    setUp(() async {
      previousCurrent = Directory.current;
      tempDir = await Directory.systemTemp.createTemp('air_cli_test_module_');
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

    test('generate creates basic module structure', () async {
      final generator = ModuleGenerator();
      await generator.generate('settings', []);

      final modulePath = path.join(tempDir.path, 'lib', 'modules', 'settings');
      expect(await Directory(modulePath).exists(), isTrue);

      expect(
        await File(path.join(modulePath, 'settings_module.dart')).exists(),
        isTrue,
      );
      expect(
        await File(
          path.join(modulePath, 'ui', 'views', 'settings_page.dart'),
        ).exists(),
        isTrue,
      );

      // Should NOT exist without --all
      expect(
        await Directory(path.join(modulePath, 'services')).exists(),
        isFalse,
      );
    });

    test('generate creates full structure with --all', () async {
      final generator = ModuleGenerator();
      await generator.generate('profile', ['--all']);

      final modulePath = path.join(tempDir.path, 'lib', 'modules', 'profile');
      expect(await Directory(modulePath).exists(), isTrue);

      expect(
        await File(path.join(modulePath, 'settings_module.dart')).exists(),
        isFalse,
      ); // Different module
      expect(
        await File(path.join(modulePath, 'profile_module.dart')).exists(),
        isTrue,
      );

      // Check extra folders
      expect(
        await Directory(path.join(modulePath, 'ui', 'state')).exists(),
        isTrue,
      );
      expect(
        await Directory(path.join(modulePath, 'services')).exists(),
        isTrue,
      );
      expect(await Directory(path.join(modulePath, 'models')).exists(), isTrue);
    });
  });
}
