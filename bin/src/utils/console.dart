import 'dart:io';
import 'package:path/path.dart' as p;

String getVersion() {
  final scriptPath = Platform.script.toFilePath();
  var packageDir = p.dirname(scriptPath);
  if (packageDir.contains('.dart_tool')) {
    packageDir = p.dirname(p.dirname(p.dirname(p.dirname(packageDir))));
  }
  final pubspec = File(p.join(packageDir, 'pubspec.yaml'));
  final content = pubspec.readAsStringSync();
  final match = RegExp(
    r'^version:\s*(\S+)',
    multiLine: true,
  ).firstMatch(content);
  return match?.group(1) ?? '0.0.0';
}

/// Console utilities for CLI output
class Console {
  static String get version => getVersion();

  static const String reset = '\x1B[0m';
  static const String bold = '\x1B[1m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';

  static void printLogo() {
    print('''
$cyan    ___    ____  ____       ______   __    ____
   /   |  /  _/ / __ \\     / ____/  / /   /  _/
  / /| |  / /  / /_/ /    / /      / /    / /
 / ___ |_/ /  / _, _/    / /___   / /___ _/ /
/_/  |_/___/ /_/ |_|     \\____/  /_____//___/$reset
''');
  }

  static void info(String message) {
    print('$blue ℹ $reset $message');
  }

  static void success(String message) {
    print('$green ✓ $reset $message');
  }

  static void warning(String message) {
    print('$yellow ⚠ $reset $message');
  }

  static void error(String message) {
    print('$red ✗ $reset $message');
  }

  static void step(int current, int total, String message) {
    print('$cyan[$current/$total]$reset $message');
  }

  static void header(String message) {
    print('\n$bold$cyan$message$reset');
    print('$cyan${'─' * message.length}$reset');
  }

  static String? prompt(String question) {
    stdout.write('$yellow? $reset$question ');
    return stdin.readLineSync();
  }

  static bool confirm(String question, {bool defaultValue = true}) {
    final defaultHint = defaultValue ? 'Y/n' : 'y/N';
    stdout.write('$yellow? $reset$question ($defaultHint) ');
    final input = stdin.readLineSync()?.toLowerCase();
    if (input == null || input.isEmpty) return defaultValue;
    return input == 'y' || input == 'yes';
  }

  static T select<T>(String question, List<SelectOption<T>> options) {
    stdout.writeln('$yellow? $reset$question');
    for (var i = 0; i < options.length; i++) {
      stdout.writeln('  ${i + 1}) ${options[i].label}');
    }

    while (true) {
      stdout.write('$yellow> ${reset}Select an option (1-${options.length}): ');
      final input = stdin.readLineSync();
      final index = int.tryParse(input ?? '') ?? -1;

      if (index >= 1 && index <= options.length) {
        return options[index - 1].value;
      }
      Console.error('Invalid selection. Please try again.');
    }
  }

  static void progress(String message) {
    stdout.write('$cyan ⋯ $reset$message\r');
  }

  static void progressDone(String message) {
    print('$green ✓ $reset$message');
  }
}

class SelectOption<T> {
  final String label;
  final T value;

  SelectOption(this.label, this.value);
}
