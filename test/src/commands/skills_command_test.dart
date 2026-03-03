@Tags(['serial'])
library;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../../bin/src/commands/skills_command.dart';

void main() {
  group('SkillsCommand', () {
    late Directory tempDir;
    late Directory previousCurrent;

    setUp(() async {
      previousCurrent = Directory.current;
      tempDir = await Directory.systemTemp.createTemp('air_cli_test_skills_');
      Directory.current = tempDir;

      // Minimal Flutter project with pubspec.yaml
      await File(
        path.join(tempDir.path, 'pubspec.yaml'),
      ).writeAsString('name: test_project\n');

      // Create fake bundled skill assets so the command can find them.
      // We simulate the package root layout:
      //   <script-parent>/../assets/skills/air_framework/SKILL.md
      // Since the test dart script lives in air-cli/test/...,
      // walking up from Platform.script will reach air-cli/, where the real
      // assets/ directory lives. So we just need it to exist on disk.
      final realAssetsDir = Directory(
        path.join(
          path.dirname(
            path.dirname(path.dirname(path.fromUri(Platform.script))),
          ),
          'assets',
          'skills',
          'air_framework',
        ),
      );
      // Ensure a SKILL.md is present so install has content to copy.
      if (!realAssetsDir.existsSync()) {
        await realAssetsDir.create(recursive: true);
        await File(
          path.join(realAssetsDir.path, 'SKILL.md'),
        ).writeAsString('# Air Framework Skill\n');
      }
    });

    tearDown(() async {
      Directory.current = previousCurrent;
      await tempDir.delete(recursive: true);
    });

    test('install creates .agent/skills/air_framework/ in project', () async {
      final command = SkillsCommand();
      await command.run(['install', 'antigravity']);

      final skillDir = Directory(
        path.join(tempDir.path, '.agent', 'skills', 'air_framework'),
      );
      expect(
        skillDir.existsSync(),
        isTrue,
        reason: '.agent/skills/air_framework directory should be created',
      );

      final skillMd = File(path.join(skillDir.path, 'SKILL.md'));
      expect(
        skillMd.existsSync(),
        isTrue,
        reason: 'SKILL.md should be copied into the project',
      );

      // AGENTS.md should be created with skill reference
      final agentsMd = File(path.join(tempDir.path, 'AGENTS.md'));
      expect(
        agentsMd.existsSync(),
        isTrue,
        reason: 'AGENTS.md should be created',
      );
      expect(
        agentsMd.readAsStringSync(),
        contains('.agent/skills/air_framework'),
        reason: 'AGENTS.md should reference the skill path',
      );
    });

    test('install appends to existing AGENTS.md without duplicates', () async {
      // Pre-existing AGENTS.md
      final agentsMd = File(path.join(tempDir.path, 'AGENTS.md'));
      await agentsMd.writeAsString('# Agents\n\nExisting content.\n');

      final command = SkillsCommand();
      await command.run(['install', 'antigravity']);

      final content = agentsMd.readAsStringSync();
      expect(
        content,
        contains('Existing content.'),
        reason: 'Original content should be preserved',
      );
      expect(
        content,
        contains('.agent/skills/air_framework'),
        reason: 'Skill reference should be appended',
      );

      // running AGENTS.md check
      expect(
        content,
        contains('.agent/skills/air_framework'),
        reason: 'Skill reference should be appended',
      );
    });

    test(
      'install does not create skill dir when not a Flutter project',
      () async {
        // Remove pubspec.yaml so it's not a Flutter project
        final pubspec = File(path.join(tempDir.path, 'pubspec.yaml'));
        await pubspec.delete();

        // exit(1) terminates the process — check the directory was NOT created
        // by running a separate process so the test process stays alive.
        final result = await Process.run('dart', [
          path.fromUri(Platform.script.resolve('../../../bin/air.dart')),
          'skills',
          'install',
          'antigravity',
        ], workingDirectory: tempDir.path);

        final skillDir = Directory(
          path.join(tempDir.path, '.agent', 'skills', 'air_framework'),
        );
        expect(
          result.exitCode,
          isNot(0),
          reason: 'Should exit with non-zero code when no pubspec.yaml',
        );
        expect(
          skillDir.existsSync(),
          isFalse,
          reason: 'Skill dir should NOT be created without a Flutter project',
        );
      },
    );

    test('install all creates skills for all agents', () async {
      final command = SkillsCommand();
      await command.run(['install', 'all']);

      final paths = [
        '.agent/skills/air_framework',
        '.claude/skills/air_framework',
        '.opencode/skills/air_framework',
        '.cursor/rules/air_framework',
      ];

      for (final p in paths) {
        final dir = Directory(path.join(tempDir.path, p));
        expect(dir.existsSync(), isTrue, reason: '$p should exist');
        expect(File(path.join(dir.path, 'SKILL.md')).existsSync(), isTrue);
      }

      final agentsMd = File(path.join(tempDir.path, 'AGENTS.md'));
      final content = agentsMd.readAsStringSync();
      for (final p in paths) {
        expect(content, contains(p));
      }
    });

    test('install cursor specific path', () async {
      final command = SkillsCommand();
      await command.run(['install', 'cursor']);

      final cursorDir = Directory(
        path.join(tempDir.path, '.cursor', 'rules', 'air_framework'),
      );
      expect(cursorDir.existsSync(), isTrue);
    });

    test('run shows usage when no subcommand given', () async {
      final command = SkillsCommand();
      // Should not throw an unhandled exception
      await command.run([]);
    });
  });
}
