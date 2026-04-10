import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../utils/file_utils.dart';

/// Template for creating a standalone community module
/// that can be shared via `air module add <git-url>`
class CommunityModuleTemplate {
  Future<void> apply(String moduleName, {String author = 'your_name'}) async {
    final snakeName = FileUtils.toSnakeCase(moduleName);
    final pascalName = FileUtils.toPascalCase(moduleName);
    final root = snakeName;

    Console.header('Creating Community Module: $pascalName');

    // module.yaml — Air manifest
    await FileUtils.createFile(
      path.join(root, 'module.yaml'),
      _moduleYaml(snakeName, pascalName, author),
    );
    Console.success('Created module.yaml');

    // pubspec.yaml — dependency declaration
    await FileUtils.createFile(
      path.join(root, 'pubspec.yaml'),
      _pubspecYaml(snakeName),
    );
    Console.success('Created pubspec.yaml');

    // README.md
    await FileUtils.createFile(
      path.join(root, 'README.md'),
      _readmeMd(snakeName, pascalName),
    );
    Console.success('Created README.md');

    // CHANGELOG.md
    await FileUtils.createFile(
      path.join(root, 'CHANGELOG.md'),
      _changelogMd(),
    );

    // .gitignore
    await FileUtils.createFile(
      path.join(root, '.gitignore'),
      _gitignore(),
    );

    // lib/<name>.dart — barrel export
    await FileUtils.createFile(
      path.join(root, 'lib', '$snakeName.dart'),
      _barrelExport(snakeName, pascalName),
    );
    Console.success('Created lib/$snakeName.dart');

    // lib/<name>_module.dart
    await FileUtils.createFile(
      path.join(root, 'lib', '${snakeName}_module.dart'),
      _moduleDart(snakeName, pascalName),
    );
    Console.success('Created lib/${snakeName}_module.dart');

    // lib/state/<name>_state.dart
    await FileUtils.createFile(
      path.join(root, 'lib', 'state', '${snakeName}_state.dart'),
      _stateDart(snakeName, pascalName),
    );
    Console.success('Created lib/state/${snakeName}_state.dart');

    // lib/services/<name>_service.dart
    await FileUtils.createFile(
      path.join(root, 'lib', 'services', '${snakeName}_service.dart'),
      _serviceDart(snakeName, pascalName),
    );
    Console.success('Created lib/services/${snakeName}_service.dart');

    // lib/ui/screens/<name>_screen.dart
    await FileUtils.createFile(
      path.join(root, 'lib', 'ui', 'screens', '${snakeName}_screen.dart'),
      _screenDart(snakeName, pascalName),
    );
    Console.success('Created lib/ui/screens/${snakeName}_screen.dart');

    // lib/ui/widgets/.gitkeep
    await FileUtils.createFile(
      path.join(root, 'lib', 'ui', 'widgets', '.gitkeep'),
      '',
    );

    print('');
    Console.success('Community module "$pascalName" created!');
    _printNextSteps(snakeName, pascalName);
  }

  void _printNextSteps(String snakeName, String pascalName) {
    print('''
${Console.cyan}Next steps:${Console.reset}
  1. Add your logic in:
     ${Console.green}lib/services/${snakeName}_service.dart${Console.reset}
     ${Console.green}lib/state/${snakeName}_state.dart${Console.reset}

  2. Update ${Console.green}module.yaml${Console.reset} with your author, repository, and dependencies

  3. Update ${Console.green}pubspec.yaml${Console.reset} with any pub.dev packages your module needs

  4. Run build_runner to generate reactive code:
     ${Console.green}dart run build_runner build${Console.reset}

  5. Push to GitHub and share with the community:
     ${Console.green}air module add https://github.com/you/$snakeName.git${Console.reset}

${Console.cyan}Module structure:${Console.reset}
  $snakeName/
  ├── module.yaml                  ← Air manifest (name, version, module_class)
  ├── pubspec.yaml                 ← pub.dev dependencies
  ├── README.md
  └── lib/
      ├── $snakeName.dart          ← barrel export
      ├── ${snakeName}_module.dart ← AppModule entry point
      ├── state/
      │   └── ${snakeName}_state.dart
      ├── services/
      │   └── ${snakeName}_service.dart
      └── ui/
          ├── screens/
          │   └── ${snakeName}_screen.dart
          └── widgets/
''');
  }

  String _moduleYaml(String snakeName, String pascalName, String author) => '''
# Air Framework Community Module Manifest
# This file is read by `air module add` to install your module

name: $snakeName
version: 1.0.0
description: A community module for Air Framework
author: $author
repository: https://github.com/$author/$snakeName

# Minimum Air Framework version required
air_framework: ">=1.0.0 <2.0.0"

# The AppModule class to register in ModuleManager
# After `air module add`, the CLI shows:
#   ModuleManager().register([${pascalName}Module()]);
module_class: ${pascalName}Module

# pub.dev dependencies needed in the consuming project
# These are auto-added by `air module add`
dependencies:
  # example:
  # supabase_flutter: ^2.3.0
''';

  String _pubspecYaml(String snakeName) => '''
name: $snakeName
description: A community module for Air Framework
version: 1.0.0

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  air_framework: ^1.0.0
  # Add your module-specific dependencies here

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.10.0
  air_generator: ^1.0.0
''';

  String _readmeMd(String snakeName, String pascalName) => '''
# $pascalName — Air Framework Module

A community module for [Air Framework](https://github.com/AndreyDAraya/air-framework).

## Install

```bash
air module add https://github.com/your_name/$snakeName.git
```

Then register it in your `main.dart`:

```dart
ModuleManager().register([${pascalName}Module()]);
```

## What it does

<!-- Describe your module here -->

## Configuration

<!-- Describe any configuration needed (env vars, adapter setup, etc.) -->

## Adapters required

<!-- List any AirAdapter the consuming project must register before this module -->
''';

  String _changelogMd() => '''
# Changelog

## 1.0.0

- Initial release
''';

  String _gitignore() => '''
.dart_tool/
build/
pubspec.lock
.DS_Store
*.g.dart
*.air.g.dart
''';

  String _barrelExport(String snakeName, String pascalName) => '''
library $snakeName;

export '${snakeName}_module.dart';
export 'state/${snakeName}_state.dart';
export 'services/${snakeName}_service.dart';
''';

  String _moduleDart(String snakeName, String pascalName) => '''
import 'package:flutter/material.dart';
import 'package:air_framework/air_framework.dart';
import 'state/${snakeName}_state.dart';
import 'services/${snakeName}_service.dart';
import 'ui/screens/${snakeName}_screen.dart';

class ${pascalName}Module extends AppModule {
  @override
  String get id => '$snakeName';

  @override
  String get name => '$pascalName';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.widgets;

  @override
  Color get color => Colors.blue;

  @override
  String get initialRoute => '/$snakeName';

  @override
  void onBind(AirDI di) {
    di.registerLazySingleton<${pascalName}Service>(() => ${pascalName}Service());
    di.registerLazySingleton<${pascalName}State>(() => ${pascalName}State());
  }

  @override
  Future<void> onInit(AirDI di) async {
    di.get<${pascalName}State>();
  }

  @override
  List<AirRoute> get routes => [
    AirRoute(
      path: '/$snakeName',
      builder: (context, state) => const ${pascalName}Screen(),
    ),
  ];
}
''';

  String _stateDart(String snakeName, String pascalName) => '''
// ignore_for_file: unused_field
import 'package:air_framework/air_framework.dart';

part '${snakeName}_state.air.g.dart';

@GenerateState('$snakeName')
class ${pascalName}State extends _${pascalName}State {

  // ═══════════════════════════════════════════════════════════════
  // STATE FLOWS — private fields become reactive AirStateKeys
  // ═══════════════════════════════════════════════════════════════

  final bool _isLoading = false;

  @override
  void onInit() {
    // Initialize your state here
  }

  // ═══════════════════════════════════════════════════════════════
  // PULSES — public void methods become dispatchable actions
  // ═══════════════════════════════════════════════════════════════

  @override
  void setLoading(bool value) {
    isLoading = value;
  }
}
''';

  String _serviceDart(String snakeName, String pascalName) => '''
/// Service for $pascalName module.
/// Keep this class pure — no dependency on Air or Flutter.
/// Inject it via AirDI in ${pascalName}Module.onBind().
class ${pascalName}Service {
  // Add your business logic and data access here

  Future<void> initialize() async {
    // Setup logic
  }
}
''';

  String _screenDart(String snakeName, String pascalName) => '''
import 'package:flutter/material.dart';
import 'package:air_framework/air_framework.dart';
import '../../state/${snakeName}_state.dart';

class ${pascalName}Screen extends StatelessWidget {
  const ${pascalName}Screen({super.key});

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
            AirView((context) {
              final isLoading = ${pascalName}Flows.isLoading.value;
              if (isLoading) return const CircularProgressIndicator();
              return const Text(
                '$pascalName ready',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ${pascalName}Pulses.setLoading.pulse(true),
              child: const Text('Test pulse'),
            ),
          ],
        ),
      ),
    );
  }
}
''';
}
