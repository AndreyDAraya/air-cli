import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../utils/file_utils.dart';

/// Base class for all generators
abstract class BaseGenerator {
  Future<void> generate(String name, List<String> args);

  /// Validates that the command is run from the root of an Air project
  void validateProjectRoot() {
    if (!FileUtils.isFlutterModulesProject(Directory.current.path)) {
      Console.error('Not in an Air project root (missing lib/modules)');
      exit(1);
    }
  }

  /// Parses the module name from arguments (e.g., --module=name)
  String? parseModuleArg(List<String> args) {
    for (final arg in args) {
      if (arg.startsWith('--module=')) {
        return arg.split('=')[1];
      }
    }
    return null;
  }

  /// Gets the path to a module and verifies it exists
  String getModulePath(String moduleName) {
    final snakeName = FileUtils.toSnakeCase(moduleName);
    final modulePath = path.join('lib', 'modules', snakeName);

    if (!Directory(modulePath).existsSync()) {
      Console.error('Module "$snakeName" does not exist at $modulePath');
      Console.info('Create it first: air g module $moduleName');
      exit(1);
    }
    return modulePath;
  }

  /// Check if a file exists and exit if it does (to prevent accidental overwrite)
  void checkFileExists(String filePath) {
    if (File(filePath).existsSync()) {
      Console.error('File already exists: $filePath');
      exit(1);
    }
  }
}
