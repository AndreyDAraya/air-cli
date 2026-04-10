import 'dart:io';
import 'package:air_cli/src/utils/asset_resolver.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('AssetResolver', () {
    test('resolve returns null if nothing can be resolved', () async {
      // Use a script URI in a temp dir with NO assets
      final tempDir = Directory.systemTemp.createTempSync('air_cli_empty_');
      try {
        final scriptFile = File(path.join(tempDir.path, 'main.dart'));
        scriptFile.createSync();
        
        final result = await AssetResolver.resolve('non_existent_package', scriptUri: scriptFile.uri);
        expect(result, isNull);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('resolve returns path to assets for air_cli', () async {
      final assetsPath = await AssetResolver.resolve('air_cli');
      expect(assetsPath, isNotNull);
      expect(assetsPath, contains('assets/skills/air_framework'));
    });

    test('resolve walks up from script URI if package resolution fails', () async {
      // Create a temp directory structure that mimics the source
      final tempDir = Directory.systemTemp.createTempSync('air_cli_test_resolver_');
      try {
        final assetsDir = Directory(path.join(tempDir.path, 'assets', 'skills', 'air_framework'));
        assetsDir.createSync(recursive: true);
        
        final binDir = Directory(path.join(tempDir.path, 'bin'));
        binDir.createSync();
        
        final scriptFile = File(path.join(binDir.path, 'air.dart'));
        scriptFile.createSync();

        // Create a dummy pubspec.yaml so resolvePackageRoot can find the root
        await File(path.join(tempDir.path, 'pubspec.yaml')).create();

        // Should resolve by walking up from the script file
        final result = await AssetResolver.resolve('non_existent_package', scriptUri: scriptFile.uri);
        expect(result, isNotNull);
        expect(result, equals(assetsDir.path));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
