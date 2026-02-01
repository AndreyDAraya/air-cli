import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../../bin/src/generators/screen_generator.dart';

void main() {
  group('ScreenGenerator', () {
    late Directory tempDir;
    late Directory previousCurrent;

    setUp(() async {
      previousCurrent = Directory.current;
      tempDir = await Directory.systemTemp.createTemp('air_cli_test_screen_');
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

    test('generate creates screen in module', () async {
      // Create module first
      final moduleName = 'products';
      final moduleDir = Directory(
        path.join(tempDir.path, 'lib', 'modules', moduleName),
      );
      await moduleDir.create(recursive: true);

      final generator = ScreenGenerator();
      await generator.generate('product_detail', ['--module=$moduleName']);

      final screenFile = File(
        path.join(moduleDir.path, 'ui', 'views', 'product_detail_page.dart'),
      );
      expect(await screenFile.exists(), isTrue);

      final content = await screenFile.readAsString();
      expect(
        content,
        contains('class ProductDetailPage extends StatefulWidget'),
      );
      expect(content, contains("title: const Text('ProductDetail')"));
    });
  });
}
