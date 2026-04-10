import 'dart:io';

String getVersion() {
  final scriptPath = Platform.script.toFilePath();
  var dir = File(scriptPath).parent;

  for (var i = 0; i < 10; i++) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    if (pubspec.existsSync()) {
      final content = pubspec.readAsStringSync();
      final match = RegExp(
        r'^version:\s*(\S+)',
        multiLine: true,
      ).firstMatch(content);
      if (match != null) return match.group(1)!;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }

  final pubCache =
      Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['HOME']}/.pub-cache';
  final parts = scriptPath.split('/');
  final airCliIndex = parts.indexOf('air_cli');
  if (airCliIndex > 0) {
    final versionMatch = RegExp(
      r'air_cli-\d+\.\d+\.\d+',
    ).firstMatch(parts.sublist(airCliIndex - 1).join('/'));
    if (versionMatch != null) {
      final pubspec = File(
        '$pubCache/hosted/pub.dev/${versionMatch.group(0)}/pubspec.yaml',
      );
      if (pubspec.existsSync()) {
        final content = pubspec.readAsStringSync();
        final match = RegExp(
          r'^version:\s*(\S+)',
          multiLine: true,
        ).firstMatch(content);
        if (match != null) return match.group(1)!;
      }
    }
  }

  return '0.0.0';
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
