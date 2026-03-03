import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../utils/file_utils.dart';
import 'base_generator.dart';

/// Generates a new Air Adapter with the recommended structure:
///
/// ```
/// lib/adapters/<name>/
/// ├── contracts/
/// │   ├── <name>_client.dart
/// │   └── <name>_response.dart
/// ├── <name>_adapter.dart
/// └── <name>_impl.dart
/// ```
class AdapterGenerator extends BaseGenerator {
  @override
  Future<void> generate(String name, List<String> args) async {
    validateProjectRoot();

    final snakeName = FileUtils.toSnakeCase(name);
    final pascalName = FileUtils.toPascalCase(name);

    Console.header('Generating Adapter: $pascalName');

    final adapterPath = path.join('lib', 'adapters', snakeName);

    // Check if adapter already exists
    if (Directory(adapterPath).existsSync()) {
      Console.error('Adapter "$snakeName" already exists');
      exit(1);
    }

    // 1. Create the abstract contract
    await FileUtils.createFile(
      path.join(adapterPath, 'contracts', '${snakeName}_client.dart'),
      _contractFile(snakeName, pascalName),
    );
    Console.success('Created contracts/${snakeName}_client.dart');

    // 2. Create the response wrapper
    await FileUtils.createFile(
      path.join(adapterPath, 'contracts', '${snakeName}_response.dart'),
      _responseFile(snakeName, pascalName),
    );
    Console.success('Created contracts/${snakeName}_response.dart');

    // 3. Create the concrete implementation
    await FileUtils.createFile(
      path.join(adapterPath, '${snakeName}_impl.dart'),
      _implFile(snakeName, pascalName),
    );
    Console.success('Created ${snakeName}_impl.dart');

    // 4. Create the adapter (extends AirAdapter)
    await FileUtils.createFile(
      path.join(adapterPath, '${snakeName}_adapter.dart'),
      _adapterFile(snakeName, pascalName),
    );
    Console.success('Created ${snakeName}_adapter.dart');

    print('');
    Console.success('Adapter "$pascalName" created with Air Framework!');
    _printNextSteps(snakeName, pascalName);
  }

  void _printNextSteps(String snakeName, String pascalName) {
    print('''

${Console.cyan}Next steps:${Console.reset}
  1. Add required dependencies in pubspec.yaml

  2. Implement the contract in ${snakeName}_impl.dart

  3. Register in main.dart (BEFORE modules):
     ${Console.green}final adapters = AdapterManager();${Console.reset}
     ${Console.green}await adapters.register(${pascalName}Adapter());${Console.reset}

  4. Use the contract in your modules:
     ${Console.green}final client = AirDI().get<${pascalName}Client>();${Console.reset}

${Console.cyan}Adapter structure:${Console.reset}
  adapters/$snakeName/
  ├── contracts/
  │   ├── ${snakeName}_client.dart     (abstract contract)
  │   └── ${snakeName}_response.dart   (response wrapper)
  ├── ${snakeName}_adapter.dart         (AirAdapter)
  └── ${snakeName}_impl.dart            (implementation)
''');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Template Files
  // ═══════════════════════════════════════════════════════════════════════════

  String _contractFile(String snakeName, String pascalName) =>
      '''
import '${snakeName}_response.dart';

/// Abstract contract for $pascalName.
///
/// Modules should depend on this interface, NOT on the concrete implementation.
/// This enables swapping the underlying library without touching module code.
///
/// ## Usage
///
/// ```dart
/// class MyService {
///   final ${pascalName}Client _client;
///   MyService(this._client);
///
///   Future<void> doSomething() async {
///     final response = await _client.execute();
///     // handle response
///   }
/// }
/// ```
abstract class ${pascalName}Client {
  // TODO: Define your abstract methods here
  //
  // Example:
  // Future<${pascalName}Response> execute(Map<String, dynamic> params);
}
''';

  String _responseFile(String snakeName, String pascalName) =>
      '''
/// Standardized response wrapper for $pascalName.
///
/// Abstracts away implementation-specific response details so that
/// modules only depend on this contract.
class ${pascalName}Response<T> {
  /// The response data.
  final T? data;

  /// Whether the operation was successful.
  final bool success;

  /// Error message if the operation failed.
  final String? error;

  const ${pascalName}Response({
    this.data,
    this.success = true,
    this.error,
  });

  @override
  String toString() =>
      '${pascalName}Response(success: \$success, data: \$data, error: \$error)';
}
''';

  String _implFile(String snakeName, String pascalName) =>
      '''
import 'contracts/${snakeName}_client.dart';

/// Concrete implementation of [${pascalName}Client].
///
/// This class wraps the underlying library behind the abstract
/// [${pascalName}Client] interface so that modules never import
/// or depend on the library directly.
class ${pascalName}ClientImpl implements ${pascalName}Client {
  // TODO: Add the underlying library instance here
  //
  // Example:
  // final SomeLibrary _lib;
  // ${pascalName}ClientImpl(this._lib);

  // TODO: Implement the abstract methods from ${pascalName}Client
}
''';

  String _adapterFile(String snakeName, String pascalName) =>
      '''
import 'package:air_framework/air_framework.dart';

import 'contracts/${snakeName}_client.dart';
import '${snakeName}_impl.dart';

/// $pascalName Adapter for the Air Framework.
///
/// Registers [${pascalName}Client] (abstract contract) in [AirDI]
/// so that modules can depend on the interface, not the implementation.
///
/// ## Registration (in main.dart, BEFORE modules)
///
/// ```dart
/// final adapters = AdapterManager();
/// await adapters.register(${pascalName}Adapter());
/// ```
///
/// ## Usage from Modules
///
/// ```dart
/// class MyModule extends AppModule {
///   @override
///   void onBind(AirDI di) {
///     di.registerLazySingleton<MyService>(
///       () => MyService(di.get<${pascalName}Client>()),
///     );
///   }
/// }
/// ```
class ${pascalName}Adapter extends AirAdapter {
  @override
  String get id => '$snakeName';

  @override
  String get name => '$pascalName';

  @override
  String get version => '1.0.0';

  @override
  void onBind(AirDI di) {
    super.onBind(di);

    // TODO: Initialize the underlying library here
    // Example:
    // final lib = SomeLibrary(config);

    // Register the abstract contract backed by the implementation
    di.registerLazySingleton<${pascalName}Client>(
      () => ${pascalName}ClientImpl(),
    );
  }

  @override
  Future<void> onDispose(AirDI di) async {
    // TODO: Clean up resources here
    super.onDispose(di);
  }
}
''';
}
