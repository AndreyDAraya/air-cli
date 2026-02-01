#!/usr/bin/env dart

/// Air Framework CLI
/// Create modular & reactive Flutter apps in minutes
library;

import 'dart:async';
import 'dart:io';
import 'src/commands/create_command.dart';
import 'src/commands/generate_command.dart';

import 'src/commands/doctor_command.dart';
import 'src/commands/module_command.dart';
import 'src/utils/console.dart';

void main(List<String> args) async {
  runZonedGuarded(
    () async {
      Console.printLogo();

      if (args.isEmpty) {
        _printUsage();
        exit(0);
      }

      final command = args[0];
      final commandArgs = args.length > 1 ? args.sublist(1) : <String>[];

      try {
        switch (command) {
          case 'create':
            await CreateCommand().run(commandArgs);
            break;
          case 'generate':
          case 'g':
            await GenerateCommand().run(commandArgs);
            break;
          case 'module':
          case 'm':
            await ModuleCommand().run(commandArgs);
            break;
          case 'pub':
            if (commandArgs.isNotEmpty && commandArgs[0] == 'add') {
              await ModuleCommand().run(commandArgs.sublist(1));
            } else {
              Console.error(
                'Only "air pub add <source>" is supported as a shortcut.',
              );
            }
            break;
          case 'doctor':
            await DoctorCommand().run(commandArgs);
            break;

          case 'help':
          case '--help':
          case '-h':
            _printUsage();
            break;
          case 'version':
          case '--version':
          case '-v':
            Console.info('Air Framework CLI v2.0.1');
            break;
          default:
            Console.error('Unknown command: $command');
            _printUsage();
            exit(1);
        }
      } catch (e, stack) {
        Console.error('Error: $e');
        if (args.contains('--verbose')) {
          print(stack);
        }
        exit(1);
      }
    },
    (error, stack) {
      Console.error('Unhandled error: $error');
      if (args.contains('--verbose')) {
        print(stack);
      }
      exit(1);
    },
  );
}

void _printUsage() {
  print('''
${Console.blue}Usage:${Console.reset} air <command> [arguments]

${Console.blue}Commands:${Console.reset}
  create <name>              Create a new Air Framework project
    --template=<template>    Template to use (blank, starter)
    --org=<org>              Organization identifier (com.example)
  
  module add <source>        Add a module (Git URL or local path)
  pub add <source>           Shortcut for module add
  
  generate <type> <name>     Generate code (aliases: g)
    module <name>            Generate a new module
    screen <name>            Generate a new screen
    service <name>           Generate a new service
    state <name>             Generate a new AirState controller
    model <name>             Generate a new model
    widget <name>            Generate a new widget
  
  doctor                     Check project configuration

  
  help                       Show this help message
  version                    Show version

${Console.blue}Examples:${Console.reset}
  air create my_app --template=starter
  air g module products
  air g screen product_detail
''');
}
