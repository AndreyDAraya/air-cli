import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../utils/file_utils.dart';
import 'base_generator.dart';

/// Generates a new service
class ServiceGenerator extends BaseGenerator {
  @override
  Future<void> generate(String name, List<String> args) async {
    validateProjectRoot();

    final snakeName = FileUtils.toSnakeCase(name);
    final pascalName = FileUtils.toPascalCase(name);

    // Get module name from args
    final moduleName = parseModuleArg(args);

    if (moduleName == null) {
      Console.error('Please specify module with --module=<name>');
      print('Example: air g service product --module=products');
      exit(1);
    }

    final modulePath = getModulePath(moduleName);
    final moduleSnake = FileUtils.toSnakeCase(moduleName);

    final servicePath = path.join(
      modulePath,
      'services',
      '${snakeName}_service.dart',
    );

    checkFileExists(servicePath);

    await FileUtils.createFile(
      servicePath,
      _serviceFile(snakeName, pascalName),
    );

    Console.success(
      'Created ${snakeName}_service.dart in $moduleSnake/services/',
    );
    print('''

${Console.cyan}Usage:${Console.reset}
  ${Console.green}final service = ${pascalName}Service();${Console.reset}
''');
  }

  String _serviceFile(String snakeName, String pascalName) =>
      '''
/// Service for $pascalName operations
class ${pascalName}Service {
  static final ${pascalName}Service _instance = ${pascalName}Service._internal();
  factory ${pascalName}Service() => _instance;
  ${pascalName}Service._internal();

  // TODO: Add your service methods
  
  Future<void> init() async {
    // Initialize
  }

  Future<List<dynamic>> getAll() async {
    // TODO: Implement
    return [];
  }

  Future<dynamic> getById(String id) async {
    // TODO: Implement
    return null;
  }

  Future<void> create(Map<String, dynamic> data) async {
    // TODO: Implement
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    // TODO: Implement
  }

  Future<void> delete(String id) async {
    // TODO: Implement
  }
}
''';
}
