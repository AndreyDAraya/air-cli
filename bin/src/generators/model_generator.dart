import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../utils/file_utils.dart';
import 'base_generator.dart';

/// Generates a new Model
class ModelGenerator extends BaseGenerator {
  @override
  Future<void> generate(String name, List<String> args) async {
    validateProjectRoot();

    final snakeName = FileUtils.toSnakeCase(name);
    final pascalName = FileUtils.toPascalCase(name);

    // Get module name or core flag
    final moduleName = parseModuleArg(args);
    bool isCore = args.contains('--core');

    String modelPath;
    if (isCore) {
      modelPath = path.join('lib', 'core', 'models');
    } else if (moduleName != null) {
      final modulePathBase = getModulePath(moduleName);
      modelPath = path.join(modulePathBase, 'models');
    } else {
      Console.error('Please specify --module=<name> or --core');
      exit(1);
    }

    final modelDir = Directory(modelPath);
    if (!modelDir.existsSync()) {
      modelDir.createSync(recursive: true);
    }

    final filePath = path.join(modelPath, '$snakeName.dart');

    checkFileExists(filePath);

    await FileUtils.createFile(filePath, _modelFile(pascalName));

    Console.success('Created model $pascalName at $modelPath');
  }

  String _modelFile(String pascalName) =>
      '''
class $pascalName {
  final String id;
  // TODO: Add more fields

  $pascalName({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  factory $pascalName.fromJson(Map<String, dynamic> json) {
    return $pascalName(
      id: json['id'] ?? '',
    );
  }

  $pascalName copyWith({
    String? id,
  }) {
    return $pascalName(
      id: id ?? this.id,
    );
  }
}
''';
}
