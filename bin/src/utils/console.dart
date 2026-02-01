import 'dart:io';

/// Console utilities for CLI output
class Console {
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

  static void progress(String message) {
    stdout.write('$cyan ⋯ $reset$message\r');
  }

  static void progressDone(String message) {
    print('$green ✓ $reset$message');
  }
}
