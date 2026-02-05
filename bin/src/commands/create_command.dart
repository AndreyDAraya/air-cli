import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../templates/blank_template.dart';
import '../templates/starter_template.dart';

/// Create command - creates a new Air project
class CreateCommand {
  Future<void> run(List<String> args) async {
    if (args.isEmpty) {
      Console.error('Please provide a project name');
      print('Usage: air create <name> [options]');
      exit(1);
    }

    // Parse arguments
    final projectName = args[0];
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
        'Invalid project name. Use lowercase letters, numbers, and underscores.',
      );
      exit(1);
    }

    // Check if directory exists
    final projectDir = Directory(projectName);
    if (projectDir.existsSync()) {
      Console.error('Directory "$projectName" already exists');
      exit(1);
    }

    Console.header('Creating Air Framework Project');
    Console.info('Name: $projectName');
    Console.info('Template: $template');
    Console.info('Organization: $org');
    print('');

    // Step 1: Create Flutter project
    Console.step(1, 4, 'Creating Flutter project...');
    final flutterResult = await Process.run('flutter', [
      'create',
      '--org',
      org,
      projectName,
    ], runInShell: true);

    if (flutterResult.exitCode != 0) {
      Console.error('Failed to create Flutter project');
      print(flutterResult.stderr);
      exit(1);
    }
    Console.success('Flutter project created');

    // Step 2: Add dependencies
    Console.step(2, 4, 'Adding dependencies...');
    await _addDependencies(projectName);
    Console.success('Dependencies added');

    // Step 3: Create folder structure
    Console.step(3, 4, 'Creating module structure...');
    await _createStructure(projectName);
    Console.success('Structure created');

    // Step 4: Apply template
    Console.step(4, 4, 'Applying $template template...');
    await _applyTemplate(projectName, template, org);
    Console.success('Template applied');

    print('');
    Console.header('Project Created Successfully! 🎉');
    print('''
${Console.cyan}Next steps:${Console.reset}
  cd $projectName
  flutter pub get
  flutter run

${Console.blue}Generate new modules:${Console.reset}
  air generate module <name>

${Console.cyan}Project structure:${Console.reset}
  lib/
  ├── main.dart
  ├── app.dart
  └── modules/        # Your feature modules (and core dependencies via package)
''');
  }

  Future<void> _addDependencies(String projectName) async {
    Console.info('Adding dependencies...');

    final dependencies = [
      'archive:^4.0.4',
      'file_picker:^8.3.7',
      'path_provider:^2.1.5',
      'path:^1.9.1',
      'go_router:^17.0.1',
    ];

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
      dependencies.add('air_framework:^1.0.0');
    }

    if (dependencies.isNotEmpty) {
      await Process.run(
        'flutter',
        ['pub', 'add', ...dependencies],
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
}
