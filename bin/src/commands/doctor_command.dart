import 'dart:io';
import '../utils/console.dart';
import '../utils/file_utils.dart';

/// Doctor command - checks project configuration
class DoctorCommand {
  Future<void> run(List<String> args) async {
    Console.header('Air Doctor');

    int passed = 0;
    int failed = 0;

    // Check Flutter
    Console.progress('Checking Flutter installation...');
    final flutterResult = await Process.run('flutter', [
      '--version',
    ], runInShell: true);
    if (flutterResult.exitCode == 0) {
      Console.progressDone('Flutter is installed');
      passed++;
    } else {
      Console.error('Flutter not found');
      failed++;
    }

    // Check Dart
    Console.progress('Checking Dart installation...');
    final dartResult = await Process.run('dart', [
      '--version',
    ], runInShell: true);
    if (dartResult.exitCode == 0) {
      Console.progressDone('Dart is installed');
      passed++;
    } else {
      Console.error('Dart not found');
      failed++;
    }

    // Check if in Flutter project
    Console.progress('Checking project structure...');
    if (FileUtils.isFlutterProject(Directory.current.path)) {
      Console.progressDone('Flutter project detected');
      passed++;

      // Check if Air project
      if (FileUtils.isFlutterModulesProject(Directory.current.path)) {
        Console.progressDone('Air structure present');
        passed++;
      } else {
        Console.warning('Not a Air project (missing lib/modules or lib/core)');
        failed++;
      }

      // Check dependencies
      Console.progress('Checking dependencies...');
      final pubspec = await File('pubspec.yaml').readAsString();
      final requiredDeps = [
        'archive',
        'path_provider',
        'path',
        'air_framework',
      ];
      final missingDeps = <String>[];

      for (final dep in requiredDeps) {
        if (!pubspec.contains(dep)) {
          missingDeps.add(dep);
        }
      }

      if (missingDeps.isEmpty) {
        Console.progressDone('All required dependencies present');
        passed++;
      } else {
        Console.warning('Missing dependencies: ${missingDeps.join(', ')}');
        failed++;
      }

      // Check modules
      Console.progress('Scanning modules...');
      final modulesDir = Directory('lib/modules');
      if (modulesDir.existsSync()) {
        final modules = modulesDir.listSync().whereType<Directory>().toList();
        Console.progressDone('Found ${modules.length} module(s)');
        for (final module in modules) {
          final name = module.path.split('/').last;
          Console.info('  • $name');
        }
        passed++;
      } else {
        Console.warning('No modules directory found');
        failed++;
      }
    } else {
      Console.warning('Not in a Flutter project');
      Console.info('Run this command from the root of a Flutter project');
    }

    // Summary
    print('');
    Console.header('Summary');
    Console.success('$passed checks passed');
    if (failed > 0) {
      Console.error('$failed checks failed');
    }
  }
}
