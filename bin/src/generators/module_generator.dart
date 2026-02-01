import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../utils/file_utils.dart';
import 'base_generator.dart';

/// Generates a new module with Air Framework architecture
class ModuleGenerator extends BaseGenerator {
  @override
  Future<void> generate(String name, List<String> args) async {
    // Only check if we are in a flutter project, creating a module is valid
    // even if lib/modules doesn't exist yet (first module)

    final snakeName = FileUtils.toSnakeCase(name);
    final pascalName = FileUtils.toPascalCase(name);

    // Parse --all flag
    bool createAll = args.contains('--all');

    Console.header('Generating Module: $pascalName');

    final modulePath = path.join('lib', 'modules', snakeName);

    // Check if module already exists
    if (Directory(modulePath).existsSync()) {
      Console.error('Module "$snakeName" already exists');
      exit(1);
    }

    // 1. Create module definition
    await FileUtils.createFile(
      path.join(modulePath, '${snakeName}_module.dart'),
      _moduleFile(snakeName, pascalName, createAll),
    );
    Console.success('Created ${snakeName}_module.dart');

    // 2. Create UI Views
    await FileUtils.createFile(
      path.join(modulePath, 'ui', 'views', '${snakeName}_page.dart'),
      _screenFile(snakeName, pascalName, createAll),
    );
    Console.success('Created ui/views/${snakeName}_page.dart');

    if (createAll) {
      // 3. Create Air State (Architecture)
      final statePath = path.join(modulePath, 'ui', 'state');

      await FileUtils.createFile(
        path.join(statePath, '${snakeName}_state.dart'),
        _stateFile(snakeName, pascalName),
      );
      await FileUtils.createFile(
        path.join(statePath, '${snakeName}_pulses.dart'),
        _pulsesFile(snakeName, pascalName),
      );
      await FileUtils.createFile(
        path.join(statePath, '${snakeName}_flows.dart'),
        _flowsFile(snakeName, pascalName),
      );
      Console.success(
        'Created ui/state/ (${snakeName}_state.dart, ${snakeName}_pulses.dart, ${snakeName}_flows.dart)',
      );

      // 4. Create Service
      await FileUtils.createFile(
        path.join(modulePath, 'services', '${snakeName}_service.dart'),
        _serviceFile(snakeName, pascalName),
      );
      Console.success('Created services/${snakeName}_service.dart');

      // 5. Create Models
      await FileUtils.createFile(
        path.join(modulePath, 'models', '.gitkeep'),
        '',
      );
      Console.success('Created models/');
    }

    print('');
    Console.success('Module "$pascalName" created with Air Framework!');

    _printNextSteps(snakeName, pascalName, createAll);
  }

  void _printNextSteps(String snakeName, String pascalName, bool createAll) {
    print('''

${Console.cyan}Next steps:${Console.reset}
  1. Register in main.dart:
     ${Console.green}manager.register(${pascalName}Module());${Console.reset}
''');

    if (createAll) {
      print('''
  2. Inject your State in the Page:
     ${Console.green}final state = AirDI().get<${pascalName}State>();${Console.reset}
''');
    }

    print('''
${Console.cyan}Air Module structure:${Console.reset}
  modules/$snakeName/
  ├── ${snakeName}_module.dart
  ├── ui/
  │   └── views/
  │       └── ${snakeName}_page.dart
''');

    if (createAll) {
      print('''
  │   └── state/
  │       ├── ${snakeName}_state.dart
  │       ├── ${snakeName}_pulses.dart
  │       └── ${snakeName}_flows.dart
  ├── services/
  └── models/
''');
    }
  }

  String _moduleFile(String snakeName, String pascalName, bool createAll) {
    if (createAll) {
      return '''
import 'package:flutter/material.dart';
import 'package:air_framework/air_framework.dart';
import 'ui/views/${snakeName}_page.dart';
import 'ui/state/${snakeName}_state.dart';

class ${pascalName}Module implements AppModule {
  @override
  String get id => '$snakeName';
  
  @override
  String get name => '$pascalName';
  
  @override
  String get version => '1.0.0';
  
  @override
  IconData get icon => Icons.widgets;
  
  @override
  Color get color => Colors.teal;
  
  @override
  String get initialRoute => '/$snakeName';
  
  @override
  void onBind() {
    // Register dependencies in DI container
    AirDI().registerLazySingleton<${pascalName}State>(() => ${pascalName}State());
  }

  @override
  Future<void> initialize() async {
    // Initialize state controller
    AirDI().get<${pascalName}State>();
  }

  @override
  List<AirRoute> get routes => [
    AirRoute(
      path: '/$snakeName',
      builder: (context, state) => const ${pascalName}Page(),
    ),
  ];
}
''';
    } else {
      return '''
import 'package:flutter/material.dart';
import 'package:air_framework/air_framework.dart';
import 'ui/views/${snakeName}_page.dart';

class ${pascalName}Module implements AppModule {
  @override
  String get id => '$snakeName';
  
  @override
  String get name => '$pascalName';
  
  @override
  String get version => '1.0.0';
  
  @override
  IconData get icon => Icons.widgets;
  
  @override
  Color get color => Colors.teal;
  
  @override
  String get initialRoute => '/$snakeName';
  
  @override
  void onBind() {}

  @override
  Future<void> initialize() async {}

  @override
  List<AirRoute> get routes => [
    AirRoute(
      path: '/$snakeName',
      builder: (context, state) => const ${pascalName}Page(),
    ),
  ];
}
''';
    }
  }

  String _screenFile(String snakeName, String pascalName, bool createAll) {
    if (createAll) {
      return '''
import 'package:flutter/material.dart';
import 'package:air_framework/air_framework.dart';

import '../state/${snakeName}_state.dart';

class ${pascalName}Page extends StatelessWidget {
  const ${pascalName}Page({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('$pascalName'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.air, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            AirBuilder<String>(
              stateKey: ${pascalName}Flows.welcomeMessage,
              initialValue: 'Loading...',
              builder: (context, message) {
                return Text(
                  message,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ${pascalName}Pulses.refresh.pulse('Hello from Air!'),
              child: const Text('Pulse refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
''';
    } else {
      return '''
import 'package:flutter/material.dart';

class ${pascalName}Page extends StatelessWidget {
  const ${pascalName}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$pascalName'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.widgets_outlined, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              '$pascalName Page',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Start building your module UI'),
          ],
        ),
      ),
    );
  }
}
''';
    }
  }

  String _stateFile(String snakeName, String pascalName) =>
      '''
import 'package:air_framework/air_framework.dart';

part '${snakeName}_pulses.dart';
part '${snakeName}_flows.dart';

class ${pascalName}State extends AirState {
  ${pascalName}State() : super(moduleId: '$snakeName');

  @override
  void onInit() {
    flow<String>(${pascalName}Flows.welcomeMessage, 'Welcome to $pascalName');
  }

  @override
  void onPulses() {
    on(${pascalName}Pulses.refresh, _handleRefresh);
  }

  void _handleRefresh(String message, {void Function()? onSuccess, void Function(String)? onError}) {
    flow<String>(${pascalName}Flows.welcomeMessage, message);
    onSuccess?.call();
  }
}
''';

  String _pulsesFile(String snakeName, String pascalName) =>
      '''
part of '${snakeName}_state.dart';

class ${pascalName}Pulses {
  static const refresh = AirPulse<String>('$snakeName.refresh');
}
''';

  String _flowsFile(String snakeName, String pascalName) =>
      '''
part of '${snakeName}_state.dart';

class ${pascalName}Flows {
  static const String welcomeMessage = '$snakeName.welcome_message';
}
''';

  String _serviceFile(String snakeName, String pascalName) =>
      '''
/// Service for $pascalName module
class ${pascalName}Service {
  // Pure service - NO dependency on Air
  Future<void> doSomething() async {
    // Business logic here
  }
}
''';
}
