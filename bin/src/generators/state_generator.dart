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
      _stateFile(snakeName, pascalName, moduleSnake),
    );
    await FileUtils.createFile(
      path.join(statePath, '${snakeName}_pulses.dart'),
      _pulsesFile(snakeName, pascalName),
    );
    await FileUtils.createFile(
      path.join(statePath, '${snakeName}_flows.dart'),
      _flowsFile(snakeName, pascalName),
    );

    Console.success('Created AirState architecture in $moduleSnake/ui/state/');
    print('''
${Console.blue}Files created:${Console.reset}
  - ${snakeName}_state.dart
  - ${snakeName}_pulses.dart
  - ${snakeName}_flows.dart

${Console.blue}Next steps:${Console.reset}
  1. Boot the state in ${moduleSnake}_module.dart:
     ${Console.green}${pascalName}State();${Console.reset}
''');
  }

  String _stateFile(String snakeName, String pascalName, String moduleSnake) =>
      '''
import 'package:air_framework/air_framework.dart';

part '${snakeName}_pulses.dart';
part '${snakeName}_flows.dart';

class ${pascalName}State extends AirState {
  ${pascalName}State() : super(moduleId: '$moduleSnake');

  @override
  void onInit() {
    // flow<String>(${pascalName}Flows.example, 'Hello Air');
  }

  @override
  void onPulses() {
    // on(${pascalName}Pulses.example, _handleExample);
  }

  // void _handleExample(String data, {void Function()? onSuccess, void Function(String)? onError}) {
  //   flow<String>(${pascalName}Flows.example, data);
  // }
}
''';

  String _pulsesFile(String snakeName, String pascalName) =>
      '''
part of '${snakeName}_state.dart';

class ${pascalName}Pulses {
  // static const example = AirPulse<String>('example.signal');
}
''';

  String _flowsFile(String snakeName, String pascalName) =>
      '''
part of '${snakeName}_state.dart';

class ${pascalName}Flows {
  // static const String example = 'example.flow';
}
''';
}
