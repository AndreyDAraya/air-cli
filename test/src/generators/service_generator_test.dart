import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../../bin/src/generators/service_generator.dart';

void main() {
  group('ServiceGenerator', () {
    late Directory tempDir;
    late Directory previousCurrent;

    setUp(() async {
      previousCurrent = Directory.current;
      tempDir = await Directory.systemTemp.createTemp('air_cli_test_service_');
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

    test('generate creates service in module', () async {
      final moduleName = 'api';
      final moduleDir = Directory(
        path.join(tempDir.path, 'lib', 'modules', moduleName),
      );
      await moduleDir.create(recursive: true);

      final generator = ServiceGenerator();
      await generator.generate('http_client', ['--module=$moduleName']);

      final serviceFile = File(
        path.join(moduleDir.path, 'services', 'http_client_service.dart'),
      );
      expect(await serviceFile.exists(), isTrue);

      final content = await serviceFile.readAsString();
      expect(content, contains('class HttpClientService'));
    });
  });
}
