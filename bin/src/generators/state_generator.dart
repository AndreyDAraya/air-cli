import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../utils/file_utils.dart';
import 'base_generator.dart';

/// Generates a new AirState architecture (state, pulses, flows)
class StateGenerator extends BaseGenerator {
  @override
  Future<void> generate(String name, List<String> args) async {
    validateProjectRoot();

    final snakeName = FileUtils.toSnakeCase(name);
    final pascalName = FileUtils.toPascalCase(name);

    // Get module name from args
    final moduleName = parseModuleArg(args);

    if (moduleName == null) {
      Console.error('Please specify module with --module=<name>');
      print('Example: air g state user_profile --module=auth');
      exit(1);
    }

    final modulePath = getModulePath(moduleName);
    final moduleSnake = FileUtils.toSnakeCase(moduleName);

    final statePath = path.join(modulePath, 'ui', 'state');

    // Create directory if it doesn't exist
    final stateDir = Directory(statePath);
    if (!stateDir.existsSync()) {
      stateDir.createSync(recursive: true);
    }

    final stateFile = path.join(statePath, '${snakeName}_state.dart');

    checkFileExists(stateFile);

    await FileUtils.createFile(
      stateFile,
      _generatorStateFile(snakeName, pascalName, moduleSnake),
    );

    Console.success('Created Reactive AirState in $moduleSnake/ui/state/');
    print('''
${Console.blue}File created:${Console.reset}
  - ${snakeName}_state.dart

${Console.blue}Next steps:${Console.reset}
  1. Boot the state in ${moduleSnake}_module.dart:
     ${Console.green}di.registerLazySingleton<${pascalName}State>(() => ${pascalName}State());${Console.reset}
  2. Run build_runner to generate the reactive code:
     ${Console.green}dart run build_runner build${Console.reset}
''');
  }

  String _generatorStateFile(
    String snakeName,
    String pascalName,
    String moduleSnake,
  ) =>
      '''
// ignore_for_file: unused_field
import 'package:air_framework/air_framework.dart';

part '${snakeName}_state.air.g.dart';

@GenerateState('$moduleSnake')
class ${pascalName}State extends _${pascalName}State {
  
  // ═══════════════════════════════════════════════════════════════════════════
  // STATE FLOWS
  // ═══════════════════════════════════════════════════════════════════════════

  final bool _isLoading = false;
  final int _count = 0;

  // ═══════════════════════════════════════════════════════════════════════════
  // PULSES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void increment() {
    count = count + 1;
  }

  @override
  void decrement() {
    count = count - 1;
  }
}
''';
}
