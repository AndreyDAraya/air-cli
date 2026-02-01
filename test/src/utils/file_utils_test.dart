import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../../bin/src/utils/file_utils.dart'; // Adjust import path if needed based on where I write this file

void main() {
  group('FileUtils', () {
    group('String manipulation', () {
      test('toSnakeCase converts strings correctly', () {
        expect(FileUtils.toSnakeCase('HelloWorld'), 'hello_world');
        expect(FileUtils.toSnakeCase('helloWorld'), 'hello_world');
        expect(FileUtils.toSnakeCase('Hello World'), 'hello_world');
        expect(FileUtils.toSnakeCase('Hello_World'), 'hello_world');
        expect(FileUtils.toSnakeCase('Simple'), 'simple');
      });

      test('toPascalCase converts strings correctly', () {
        expect(FileUtils.toPascalCase('hello_world'), 'HelloWorld');
        expect(FileUtils.toPascalCase('hello-world'), 'HelloWorld');
        expect(FileUtils.toPascalCase('hello world'), 'HelloWorld');
        expect(FileUtils.toPascalCase('HelloWorld'), 'HelloWorld');
      });

      test('toCamelCase converts strings correctly', () {
        expect(FileUtils.toCamelCase('hello_world'), 'helloWorld');
        expect(FileUtils.toCamelCase('hello-world'), 'helloWorld');
        expect(FileUtils.toCamelCase('Hello World'), 'helloWorld');
        expect(FileUtils.toCamelCase('HelloWorld'), 'helloWorld');
      });
    });

    group('File System operations', () {
      late Directory tempDir;

      setUp(() async {
        tempDir = await Directory.systemTemp.createTemp('air_cli_test_');
      });

      tearDown(() async {
        await tempDir.delete(recursive: true);
      });

      test('createFile creates a file with content', () async {
        final filePath = path.join(tempDir.path, 'test_file.txt');
        final content = 'Hello, Test!';

        await FileUtils.createFile(filePath, content);

        final file = File(filePath);
        expect(await file.exists(), isTrue);
        expect(await file.readAsString(), content);
      });

      test('createFile creates parent directories if needed', () async {
        final filePath = path.join(
          tempDir.path,
          'nested',
          'dir',
          'test_file.txt',
        );
        final content = 'Nested content';

        await FileUtils.createFile(filePath, content);

        final file = File(filePath);
        expect(await file.exists(), isTrue);
        expect(await file.readAsString(), content);
      });

      test('copyDirectory copies files recursively', () async {
        // Setup source directory
        final sourceDir = Directory(path.join(tempDir.path, 'source'));
        await sourceDir.create();
        await FileUtils.createFile(
          path.join(sourceDir.path, 'file1.txt'),
          'content1',
        );
        await FileUtils.createFile(
          path.join(sourceDir.path, 'sub', 'file2.txt'),
          'content2',
        );

        // Setup destination directory
        final destDir = Directory(path.join(tempDir.path, 'dest'));

        // Perform copy
        await FileUtils.copyDirectory(sourceDir, destDir);

        // Verify
        expect(
          await File(path.join(destDir.path, 'file1.txt')).exists(),
          isTrue,
        );
        expect(
          await File(path.join(destDir.path, 'sub', 'file2.txt')).exists(),
          isTrue,
        );
        expect(
          await File(path.join(destDir.path, 'file1.txt')).readAsString(),
          'content1',
        );
      });

      test('isFlutterProject detects pubspec.yaml', () async {
        final projectDir = Directory(
          path.join(tempDir.path, 'flutter_project'),
        );
        await projectDir.create();
        await FileUtils.createFile(
          path.join(projectDir.path, 'pubspec.yaml'),
          'name: test',
        );

        expect(FileUtils.isFlutterProject(projectDir.path), isTrue);
      });

      test(
        'isFlutterProject returns false when pubspec.yaml is missing',
        () async {
          final emptyDir = Directory(path.join(tempDir.path, 'empty'));
          await emptyDir.create();

          expect(FileUtils.isFlutterProject(emptyDir.path), isFalse);
        },
      );
    });
  });
}
