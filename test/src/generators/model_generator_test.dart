import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../../bin/src/generators/model_generator.dart';

void main() {
  group('ModelGenerator', () {
    late Directory tempDir;
    late Directory previousCurrent;

    setUp(() async {
      previousCurrent = Directory.current;
      tempDir = await Directory.systemTemp.createTemp('air_cli_test_model_');
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

    test('generate creates model in core when --core flag is used', () async {
      final generator = ModelGenerator();
      await generator.generate('user_profile', ['--core']);

      final modelFile = File(
        path.join(tempDir.path, 'lib', 'core', 'models', 'user_profile.dart'),
      );
      expect(await modelFile.exists(), isTrue);

      final content = await modelFile.readAsString();
      expect(content, contains('class UserProfile'));
      expect(content, contains('final String id;'));
      expect(content, contains('UserProfile copyWith'));
    });

    test('generate creates model in module when --module is used', () async {
      // Create module first
      final moduleName = 'auth';
      final moduleDir = Directory(
        path.join(tempDir.path, 'lib', 'modules', 'auth'),
      );
      await moduleDir.create(recursive: true);

      final generator = ModelGenerator();
      await generator.generate('auth_token', ['--module=$moduleName']);

      final modelFile = File(
        path.join(moduleDir.path, 'models', 'auth_token.dart'),
      );
      expect(await modelFile.exists(), isTrue);

      final content = await modelFile.readAsString();
      expect(content, contains('class AuthToken'));
    });
  });
}
