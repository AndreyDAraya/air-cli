import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../utils/file_utils.dart';
import 'base_generator.dart';

/// Generates a new reusable Widget
class WidgetGenerator extends BaseGenerator {
  @override
  Future<void> generate(String name, List<String> args) async {
    validateProjectRoot();

    final snakeName = FileUtils.toSnakeCase(name);
    final pascalName = FileUtils.toPascalCase(name);

    // Get module name from args
    final moduleName = parseModuleArg(args);

    if (moduleName == null) {
      Console.error('Please specify module with --module=<name>');
      exit(1);
    }

    final modulePath = getModulePath(moduleName);
    final moduleSnake = FileUtils.toSnakeCase(moduleName);

    final widgetPath = path.join(modulePath, 'ui', 'widgets');
    final widgetDir = Directory(widgetPath);
    if (!widgetDir.existsSync()) {
      widgetDir.createSync(recursive: true);
    }

    final filePath = path.join(widgetPath, '${snakeName}_widget.dart');

    checkFileExists(filePath);

    await FileUtils.createFile(filePath, _widgetFile(pascalName));

    Console.success(
      'Created widget ${pascalName}Widget in $moduleSnake/ui/widgets/',
    );
  }

  String _widgetFile(String pascalName) =>
      '''
import 'package:flutter/material.dart';

class ${pascalName}Widget extends StatelessWidget {
  const ${pascalName}Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: const Text('$pascalName Widget'),
    );
  }
}
''';
}
