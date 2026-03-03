import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../../bin/src/generators/adapter_generator.dart';

void main() {
  group('AdapterGenerator', () {
    late Directory tempDir;
    late Directory previousCurrent;

    setUp(() async {
      previousCurrent = Directory.current;
      tempDir = await Directory.systemTemp.createTemp('air_cli_test_adapter_');
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

    test('generate creates adapter folder structure', () async {
      final generator = AdapterGenerator();
      await generator.generate('sentry', []);

      final adapterDir = path.join(tempDir.path, 'lib', 'adapters', 'sentry');

      // Verify all files were created
      expect(
        await File(path.join(adapterDir, 'sentry_adapter.dart')).exists(),
        isTrue,
      );
      expect(
        await File(path.join(adapterDir, 'sentry_impl.dart')).exists(),
        isTrue,
      );
      expect(
        await File(
          path.join(adapterDir, 'contracts', 'sentry_client.dart'),
        ).exists(),
        isTrue,
      );
      expect(
        await File(
          path.join(adapterDir, 'contracts', 'sentry_response.dart'),
        ).exists(),
        isTrue,
      );
    });

    test('generated files contain correct class names', () async {
      final generator = AdapterGenerator();
      await generator.generate('analytics', []);

      final adapterDir = path.join(
        tempDir.path,
        'lib',
        'adapters',
        'analytics',
      );

      final adapterContent = await File(
        path.join(adapterDir, 'analytics_adapter.dart'),
      ).readAsString();
      expect(adapterContent, contains('class AnalyticsAdapter'));
      expect(adapterContent, contains('extends AirAdapter'));

      final contractContent = await File(
        path.join(adapterDir, 'contracts', 'analytics_client.dart'),
      ).readAsString();
      expect(contractContent, contains('abstract class AnalyticsClient'));

      final implContent = await File(
        path.join(adapterDir, 'analytics_impl.dart'),
      ).readAsString();
      expect(implContent, contains('class AnalyticsClientImpl'));
      expect(implContent, contains('implements AnalyticsClient'));

      final responseContent = await File(
        path.join(adapterDir, 'contracts', 'analytics_response.dart'),
      ).readAsString();
      expect(responseContent, contains('class AnalyticsResponse'));
    });
  });
}
