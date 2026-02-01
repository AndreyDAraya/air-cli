import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../utils/file_utils.dart';
import 'base_generator.dart';

/// Generates a new screen
class ScreenGenerator extends BaseGenerator {
  @override
  Future<void> generate(String name, List<String> args) async {
    validateProjectRoot();

    final snakeName = FileUtils.toSnakeCase(name);
    final pascalName = FileUtils.toPascalCase(name);

    // Get module name from args
    final moduleName = parseModuleArg(args);

    if (moduleName == null) {
      Console.error('Please specify module with --module=<name>');
      print('Example: air g screen product_detail --module=products');
      exit(1);
    }

    final modulePath = getModulePath(moduleName);
    final moduleSnake = FileUtils.toSnakeCase(moduleName);

    final screenPath = path.join(
      modulePath,
      'ui',
      'views',
      '${snakeName}_page.dart',
    );

    checkFileExists(screenPath);

    await FileUtils.createFile(screenPath, _screenFile(snakeName, pascalName));

    Console.success('Created ${snakeName}_page.dart in $moduleSnake/ui/views/');
    print('''

${Console.cyan}Next steps:${Console.reset}
  Add route in ${moduleSnake}_module.dart:
  ${Console.green}'/$moduleSnake/$snakeName': (_) => const ${pascalName}Page(),${Console.reset}
''');
  }

  String _screenFile(String snakeName, String pascalName) =>
      '''
import 'package:flutter/material.dart';

class ${pascalName}Page extends StatefulWidget {
  const ${pascalName}Page({super.key});

  @override
  State<${pascalName}Page> createState() => _${pascalName}PageState();
}

class _${pascalName}PageState extends State<${pascalName}Page> {
  @override
  void initState() {
    super.initState();
    // TODO: Initialize
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$pascalName'),
      ),
      body: const Center(
        child: Text('$pascalName Page'),
      ),
    );
  }
}
''';
}
