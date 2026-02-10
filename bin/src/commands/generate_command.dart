import 'dart:io';
import '../utils/console.dart';
import '../utils/file_utils.dart';
import '../generators/module_generator.dart';
import '../generators/screen_generator.dart';
import '../generators/service_generator.dart';
import '../generators/state_generator.dart';
import '../generators/model_generator.dart';
import '../generators/widget_generator.dart';

/// Generate command - generates scaffolding code
class GenerateCommand {
  Future<void> run(List<String> args) async {
    if (args.isEmpty) {
      Console.error('Please specify what to generate');
      _printUsage();
      exit(1);
    }

    // Check if in a Air project
    if (!FileUtils.isFlutterModulesProject(Directory.current.path)) {
      Console.error('Not in a Air project');
      Console.info('Run this command from the root of a Air project');
      exit(1);
    }

    final type = args[0];
    final name = args.length > 1 ? args[1] : null;

    if (name == null) {
      Console.error('Please provide a name');
      _printUsage();
      exit(1);
    }

    switch (type) {
      case 'module':
      case 'm':
        await ModuleGenerator().generate(name, args);
        break;
      case 'screen':
      case 'page':
      case 'view':
      case 's':
      case 'p':
      case 'v':
        await ScreenGenerator().generate(name, args);
        break;
      case 'service':
      case 'svc':
        await ServiceGenerator().generate(name, args);
        break;
      case 'state':
      case 'st':
        await StateGenerator().generate(name, args);
        break;
      case 'model':
      case 'mod':
        await ModelGenerator().generate(name, args);
        break;
      case 'widget':
      case 'w':
        await WidgetGenerator().generate(name, args);
        break;
      default:
        Console.error('Unknown generator type: $type');
        _printUsage();
        exit(1);
    }
  }

  void _printUsage() {
    print('''

Usage: air generate <type> <name> [options]

Types:
  module, m     Generate a new module (--all for full structure)
  screen, page, view, s, p, v  Generate a new screen (--module=<module>)
  service, svc  Generate a new service (--module=<module>)
  state, st     Generate a new AirState controller (--module=<module>)
  model, mod    Generate a new model (--module=<module> | --core)
  widget, w     Generate a new widget (--module=<module>)

Examples:
  air generate module products
  air g screen product_list --module=products
  air g service product --module=products
''');
  }
}
