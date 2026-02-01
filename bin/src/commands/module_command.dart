import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';

class ModuleCommand {
  Future<void> run(List<String> args) async {
    if (args.isEmpty) {
      _printUsage();
      return;
    }

    final subCommand = args[0];
    final subCommandArgs = args.length > 1 ? args.sublist(1) : <String>[];

    switch (subCommand) {
      case 'add':
        await _handleAdd(subCommandArgs);
        break;
      default:
        Console.error('Unknown module command: $subCommand');
        _printUsage();
        exit(1);
    }
  }

  void _printUsage() {
    print('''
${Console.blue}Usage:${Console.reset} air module <command> [arguments]

${Console.blue}Commands:${Console.reset}
  add <source>        Add a module from a Git URL or local path
''');
  }

  Future<void> _handleAdd(List<String> args) async {
    if (args.isEmpty) {
      Console.error('Please provide a module source (Git URL or local path)');
      exit(1);
    }

    final source = args[0];
    final isGit =
        source.endsWith('.git') ||
        source.startsWith('https://') ||
        source.startsWith('git@');

    // 1. Determine destination
    final modulesDir = Directory('lib/modules');
    if (!modulesDir.existsSync()) {
      Console.error(
        'Could not find "lib/modules" directory. Are you in an Air Framework project root?',
      );
      exit(1);
    }

    String tempPath = '';
    String moduleSourcePath = '';

    try {
      if (isGit) {
        Console.info('Fetching module from Git: $source');
        tempPath = path.join(
          Directory.systemTemp.path,
          'air_module_${DateTime.now().millisecondsSinceEpoch}',
        );

        final result = await Process.run('git', [
          'clone',
          '--depth',
          '1',
          source,
          tempPath,
        ]);
        if (result.exitCode != 0) {
          Console.error('Failed to clone repository: ${result.stderr}');
          exit(1);
        }
        moduleSourcePath = tempPath;
      } else {
        Console.info('Adding module from local path: $source');
        moduleSourcePath = source;
        if (!Directory(moduleSourcePath).existsSync()) {
          Console.error('Local path does not exist: $moduleSourcePath');
          exit(1);
        }
      }

      // 2. Identify module name
      // Try to find a manifest or use directory name
      String moduleName = path.basename(moduleSourcePath);
      final manifestFile = File(path.join(moduleSourcePath, 'module.yaml'));
      if (manifestFile.existsSync()) {
        // Simple parsing for name
        final content = manifestFile.readAsStringSync();
        final match = RegExp(r'name:\s*(.*)').firstMatch(content);
        if (match != null) {
          moduleName = match.group(1)!.trim();
        }
      }

      Console.info('Installing module: $moduleName');
      final targetPath = path.join('lib/modules', moduleName);

      if (Directory(targetPath).existsSync()) {
        Console.warning(
          'Module "$moduleName" already exists at $targetPath. Overwriting...',
        );
        await Directory(targetPath).delete(recursive: true);
      }

      // 3. Copy module files
      // We assume the module code is in the root of the source or in a 'lib' folder
      // For this implementation, we copy everything except .git
      await _copyDirectory(Directory(moduleSourcePath), Directory(targetPath));

      // 4. Sync dependencies
      await _syncDependencies(moduleSourcePath);

      Console.success('Module "$moduleName" installed successfully!');

      // 5. Run pub get
      Console.info('Running flutter pub get...');
      await Process.run('flutter', ['pub', 'get'], runInShell: true);
    } finally {
      if (tempPath.isNotEmpty && Directory(tempPath).existsSync()) {
        await Directory(tempPath).delete(recursive: true);
      }
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (var entity in source.list(recursive: false)) {
      if (entity is Directory) {
        if (path.basename(entity.path) == '.git') continue;
        final newDirectory = Directory(
          path.join(destination.absolute.path, path.basename(entity.path)),
        );
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        await entity.copy(
          path.join(destination.path, path.basename(entity.path)),
        );
      }
    }
  }

  Future<void> _syncDependencies(String moduleSourcePath) async {
    final modulePubspecFile = File(path.join(moduleSourcePath, 'pubspec.yaml'));
    if (!modulePubspecFile.existsSync()) return;

    Console.info('Syncing dependencies from module...');

    final content = await modulePubspecFile.readAsString();
    // Improved extraction using regex for key-value pairs
    final depSection = RegExp(
      r'dependencies:([\s\S]*?)(?=\n\S|$)',
    ).firstMatch(content);

    if (depSection == null) return;

    final depLines = depSection.group(1)!.split('\n');
    final dependenciesToAdd = <String>[];

    for (var line in depLines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      if (line.startsWith('flutter:') || line.startsWith('sdk:')) continue;

      final parts = line.split(':');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        var version = parts.sublist(1).join(':').trim();

        // Handle simple versioning or empty (any)
        if (version.isEmpty) {
          dependenciesToAdd.add(name);
        } else {
          // Remove potential comments or extra stuff
          version = version.split('#')[0].trim();
          dependenciesToAdd.add('$name:$version');
        }
      }
    }

    if (dependenciesToAdd.isEmpty) {
      Console.info('No new dependencies to add.');
      return;
    }

    for (final dep in dependenciesToAdd) {
      Console.info('Adding dependency: $dep');
      final result = await Process.run('flutter', [
        'pub',
        'add',
        dep,
      ], runInShell: true);

      if (result.exitCode != 0) {
        Console.warning('Failed to add dependency "$dep": ${result.stderr}');
      } else {
        Console.success('Added dependency "$dep"');
      }
    }
  }
}
