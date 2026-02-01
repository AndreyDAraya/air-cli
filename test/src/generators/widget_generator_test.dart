import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../../bin/src/generators/widget_generator.dart';

void main() {
  group('WidgetGenerator', () {
    late Directory tempDir;
    late Directory previousCurrent;

    setUp(() async {
      previousCurrent = Directory.current;
      tempDir = await Directory.systemTemp.createTemp('air_cli_test_widget_');
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

    test('generate creates widget in module', () async {
      final moduleName = 'dashboard';
      final moduleDir = Directory(
        path.join(tempDir.path, 'lib', 'modules', moduleName),
      );
      await moduleDir.create(recursive: true);

      final generator = WidgetGenerator();
      await generator.generate('chart_card', ['--module=$moduleName']);

      final widgetFile = File(
        path.join(moduleDir.path, 'ui', 'widgets', 'chart_card_widget.dart'),
      );
      expect(await widgetFile.exists(), isTrue);

      final content = await widgetFile.readAsString();
      expect(
        content,
        contains('class ChartCardWidget extends StatelessWidget'),
      );
    });
  });
}
