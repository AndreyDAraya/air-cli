import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// File utilities for CLI operations
class FileUtils {
  /// Copy directory recursively
  static Future<void> copyDirectory(
    Directory source,
    Directory destination,
  ) async {
    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }

    await for (final entity in source.list(recursive: false)) {
      final newPath = path.join(destination.path, path.basename(entity.path));
      if (entity is File) {
        await entity.copy(newPath);
      } else if (entity is Directory) {
        await copyDirectory(entity, Directory(newPath));
      }
    }
  }

  /// Create file with content
  static Future<void> createFile(String filePath, String content) async {
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  /// Check if running in a Flutter project
  static bool isFlutterProject(String dir) {
    return File(path.join(dir, 'pubspec.yaml')).existsSync();
  }

  /// Check if running in an Air project
  static bool isFlutterModulesProject(String dir) {
    return Directory(path.join(dir, 'lib', 'modules')).existsSync();
  }

  /// Convert to snake_case
  static String toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceAll(RegExp(r'^_'), '')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  /// Convert to PascalCase
  static String toPascalCase(String input) {
    return toSnakeCase(input)
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join('');
  }

  /// Convert to camelCase
  static String toCamelCase(String input) {
    final pascal = toPascalCase(input);
    return pascal.isEmpty
        ? ''
        : '${pascal[0].toLowerCase()}${pascal.substring(1)}';
  }

  /// Convert map to formatted JSON string
  static String toJson(Map<String, dynamic> map) {
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
