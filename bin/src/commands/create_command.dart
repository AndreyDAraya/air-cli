import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../templates/blank_template.dart';
import '../templates/starter_template.dart';
import 'skills_command.dart';

/// Create command - creates a new Air project
class CreateCommand {
  Future<void> run(List<String> args) async {
    if (args.isEmpty) {
      Console.error('Please provide a project name');
      print('Usage: air create <name> [options]');
      exit(1);
    }

    // Parse arguments
    final inputName = args[0];
    final isCurrentDir = inputName == '.';
    final projectPath = isCurrentDir ? '.' : inputName;
    String projectName = isCurrentDir
        ? path.basename(Directory.current.absolute.path)
        : inputName;

    // Sanitize project name (snake_case)
    projectName = _sanitizeProjectName(projectName);

    String template = 'blank';
    String org = 'com.example';

    for (int i = 1; i < args.length; i++) {
      final arg = args[i];
      if (arg == '--template' && i + 1 < args.length) {
        template = args[++i];
      } else if (arg.startsWith('--template=')) {
        template = arg.split('=')[1];
      } else if (arg == '--org' && i + 1 < args.length) {
        org = args[++i];
      } else if (arg.startsWith('--org=')) {
        org = arg.split('=')[1];
      }
    }

    // Validate project name
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(projectName)) {
      Console.error(
        'Invalid project name "$projectName". Use lowercase letters, numbers, and underscores.',
      );
      exit(1);
    }

    // Check if directory exists (only if not current dir)
    if (!isCurrentDir) {
      final projectDir = Directory(projectPath);
      if (projectDir.existsSync()) {
        Console.error('Directory "$projectPath" already exists');
        exit(1);
      }
    }

    Console.header('Creating Air Framework Project');
    Console.info('Name: $projectName');
    Console.info('Template: $template');
    Console.info('Organization: $org');
    print('');

    // Step 1: Create Flutter project
    Console.step(1, 6, 'Creating Flutter project...');
    final flutterResult = await Process.run('flutter', [
      'create',
      '--org',
      org,
      '--project-name',
      projectName,
      projectPath,
    ], runInShell: true);

    if (flutterResult.exitCode != 0) {
      Console.error('Failed to create Flutter project');
      print(flutterResult.stderr);
      exit(1);
    }
    Console.success('Flutter project created');

    // Step 2: Add dependencies
    Console.step(2, 6, 'Adding dependencies...');
    await _addDependencies(projectPath);
    Console.success('Dependencies added');

    // Step 3: Create folder structure
    Console.step(3, 6, 'Creating module structure...');
    await _createStructure(projectPath);
    Console.success('Structure created');

    // Step 4: Apply template
    Console.step(4, 6, 'Applying $template template...');
    await _applyTemplate(projectPath, template, org);
    Console.success('Template applied');

    // Step 5: Run Build Runner
    Console.step(5, 6, 'Generating code...');
    await _runBuildRunner(projectPath);
    Console.success('Code generated');

    // Step 6: Install Air Framework skill
    Console.step(6, 6, 'Installing Air Framework skill...');
    final previousDir = Directory.current;
    Directory.current = Directory(projectPath);
    try {
      await SkillsCommand().run(['install']);
    } catch (_) {
      Console.warning(
        'Could not auto-install skill. Run "air skills install" manually.',
      );
    } finally {
      Directory.current = previousDir;
    }

    print('');
    Console.header('Project Created Successfully! 🎉');
    print('''
${Console.cyan}Next steps:${Console.reset}
  ${isCurrentDir ? '' : 'cd $projectName\n  '}flutter pub get
  flutter run

${Console.blue}Generate new modules:${Console.reset}
  air generate module <name>

${Console.cyan}Project structure:${Console.reset}
  lib/
  ├── main.dart
  ├── app.dart
  └── modules/        # Your feature modules
  .agent/skills/       # AI agent skill (auto-installed)
  AGENTS.md            # Agent guidelines
''');
  }

  Future<void> _addDependencies(String projectName) async {
    Console.info('Adding dependencies...');

    final dependencies = ['go_router'];
    final devDependencies = ['build_runner', 'air_generator'];

    // Air Framework dependency
    // Check for environment variable for local dev, otherwise use git/pub
    final localPath = Platform.environment['AIR_FRAMEWORK_PATH'];
    if (localPath != null) {
      Console.info('Using local Air Framework from: $localPath');
      // We have to add path dependency manually or via pub add --path
      await Process.run(
        'flutter',
        ['pub', 'add', 'air_framework', '--path', localPath],
        workingDirectory: projectName,
        runInShell: true,
      );
    } else {
      // Default to hosted version for production
      dependencies.add('air_framework');
    }

    if (dependencies.isNotEmpty) {
      await Process.run(
        'flutter',
        ['pub', 'add', ...dependencies],
        workingDirectory: projectName,
        runInShell: true,
      );
    }

    if (devDependencies.isNotEmpty) {
      await Process.run(
        'flutter',
        ['pub', 'add', '--dev', ...devDependencies],
        workingDirectory: projectName,
        runInShell: true,
      );
    }

    // Run pub get to be sure
    await Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: projectName,
      runInShell: true,
    );
  }

  Future<void> _runBuildRunner(String projectName) async {
    Console.info('Generating code...');
    await Process.run(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      workingDirectory: projectName,
      runInShell: true,
    );
  }

  Future<void> _createStructure(String projectName) async {
    final directories = ['lib/modules'];

    for (final dir in directories) {
      await Directory(path.join(projectName, dir)).create(recursive: true);
    }

    // Delete default test file
    final testFile = File(path.join(projectName, 'test', 'widget_test.dart'));
    if (testFile.existsSync()) {
      await testFile.delete();
    }

    // Create analysis_options.yaml
    await _createAnalysisOptions(projectName);
  }

  Future<void> _createAnalysisOptions(String projectName) async {
    final content = '''
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Add your rules here

analyzer:
  errors:
    unused_field: ignore
''';

    await File(
      path.join(projectName, 'analysis_options.yaml'),
    ).writeAsString(content);
  }

  Future<void> _applyTemplate(
    String projectName,
    String template,
    String org,
  ) async {
    switch (template) {
      case 'blank':
        await BlankTemplate().apply(projectName, org);
        break;
      case 'starter':
        await StarterTemplate().apply(projectName, org);
        break;

      default:
        Console.warning('Unknown template "$template", using blank');
        await BlankTemplate().apply(projectName, org);
    }
  }

  String _sanitizeProjectName(String name) {
    var sanitized = name
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z0-9_]'),
          '_',
        ) // Replace non-alphanumeric with _
        .replaceAll(RegExp(r'_+'), '_'); // Collapse multiple underscores

    // Remove leading/trailing underscores
    sanitized = sanitized.replaceAll(RegExp(r'^_+|_+$'), '');

    // Ensure it starts with a letter
    if (sanitized.isEmpty || !RegExp(r'^[a-z]').hasMatch(sanitized)) {
      sanitized = 'air_$sanitized';
    }

    return sanitized;
  }
}
