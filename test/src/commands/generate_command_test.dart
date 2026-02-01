import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../../bin/src/commands/generate_command.dart';

void main() {
  group('GenerateCommand', () {
    late Directory tempDir;
    late Directory previousCurrent;

    setUp(() async {
      previousCurrent = Directory.current;
      tempDir = await Directory.systemTemp.createTemp('air_cli_test_generate_');
      Directory.current = tempDir;

      // Setup minimal Air project structure
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

    test('run calls ModuleGenerator when type is module', () async {
      final command = GenerateCommand();
      await command.run(['module', 'settings']);

      final modulePath = path.join(tempDir.path, 'lib', 'modules', 'settings');
      expect(await Directory(modulePath).exists(), isTrue);
    });

    test('run calls ScreenGenerator when type is screen', () async {
      // Need a module first
      await Directory(
        path.join(tempDir.path, 'lib', 'modules', 'home'),
      ).create();

      final command = GenerateCommand();
      await command.run(['screen', 'details', '--module=home']);

      final screenPath = path.join(
        tempDir.path,
        'lib',
        'modules',
        'home',
        'ui',
        'views',
        'details_page.dart',
      );
      expect(await File(screenPath).exists(), isTrue);
    });

    test('run calls ScreenGenerator when type is alias s', () async {
      // Need a module first
      await Directory(
        path.join(tempDir.path, 'lib', 'modules', 'home'),
      ).create();

      final command = GenerateCommand();
      await command.run(['s', 'details2', '--module=home']);

      final screenPath = path.join(
        tempDir.path,
        'lib',
        'modules',
        'home',
        'ui',
        'views',
        'details2_page.dart',
      );
      expect(await File(screenPath).exists(), isTrue);
    });

    // We can add similar tests for other types to verify the switch case logic
    test('run calls ServiceGenerator', () async {
      await Directory(
        path.join(tempDir.path, 'lib', 'modules', 'home'),
      ).create();
      final command = GenerateCommand();
      await command.run(['service', 'api', '--module=home']);
      expect(
        await File(
          path.join(
            tempDir.path,
            'lib',
            'modules',
            'home',
            'services',
            'api_service.dart',
          ),
        ).exists(),
        isTrue,
      );
    });
  });
}
