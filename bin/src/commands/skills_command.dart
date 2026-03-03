import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../utils/file_utils.dart';

/// Skills command - manages agent skills for the Air Framework.
///
/// Usage:
///   air skills install     Installs the Air Framework agent skill into the project
class SkillsCommand {
  Future<void> run(List<String> args) async {
    if (args.isEmpty) {
      _printUsage();
      return;
    }

    final subCommand = args[0];

    switch (subCommand) {
      case 'install':
        final agentArg = args.length > 1 ? args[1] : null;
        await _handleInstall(agentArg);
        break;
      default:
        Console.error('Unknown skills command: $subCommand');
        _printUsage();
        exit(1);
    }
  }

  void _printUsage() {
    print('''
${Console.blue}Usage:${Console.reset} air skills <command> [args]

${Console.blue}Commands:${Console.reset}
  install [agent]  Install the Air Framework agent skill for a specific AI agent.
                   Supported: antigravity, claude, opencode, cursor, all
                   If [agent] is omitted, an interactive menu will appear.

${Console.blue}Examples:${Console.reset}
  air skills install
  air skills install cursor
  air skills install all
''');
  }

  Future<void> _handleInstall([String? agentArg]) async {
    final projectDir = Directory.current.path;

    // 1. Verify we're inside a Flutter project
    if (!FileUtils.isFlutterProject(projectDir)) {
      Console.error(
        'No pubspec.yaml found. Are you in the root of a Flutter/Air project?',
      );
      exit(1);
    }

    final agents = <AgentInfo>[
      AgentInfo('Antigravity', '.agent/skills/'),
      AgentInfo('Claude Code', '.claude/skills/'),
      AgentInfo('OpenCode', '.opencode/skills/'),
      AgentInfo('Cursor', '.cursor/rules/'),
    ];

    List<AgentInfo> selectedAgents = [];

    if (agentArg != null) {
      if (agentArg.toLowerCase() == 'all') {
        selectedAgents = agents;
      } else {
        final agent = agents.firstWhere(
          (a) =>
              a.name.toLowerCase().replaceAll(' ', '') ==
              agentArg.toLowerCase(),
          orElse: () {
            Console.error('Unknown agent: $agentArg');
            exit(1);
          },
        );
        selectedAgents = [agent];
      }
    } else {
      Console.header('Installing Air Framework agent skill');
      final options = [
        ...agents.map((a) => SelectOption(a.name, [a])),
        SelectOption('All (Install for all agents)', agents),
      ];

      selectedAgents = Console.select(
        'Which AI agent do you want to install for?',
        options,
      );
    }

    // 2. Locate the bundled skill assets
    final skillSource = _resolveSkillSourceDir();
    if (skillSource == null || !Directory(skillSource).existsSync()) {
      Console.error(
        'Could not locate bundled skill assets.\n'
        '  Expected path: ${skillSource ?? "<unresolved>"}\n'
        '  Please re-activate the CLI with: dart pub global activate air_cli',
      );
      exit(1);
    }

    for (final agent in selectedAgents) {
      await _installForAgent(projectDir, skillSource, agent);
    }
  }

  Future<void> _installForAgent(
    String projectDir,
    String skillSource,
    AgentInfo agent,
  ) async {
    Console.info('Installing for ${agent.name}...');

    // 3. Determine the target path inside the project
    final targetPath = path.join(projectDir, agent.skillPath, 'air_framework');
    final targetDir = Directory(targetPath);

    if (targetDir.existsSync()) {
      Console.warning(
        'Skill already installed for ${agent.name} at $targetPath',
      );
      final overwrite = Console.confirm(
        'Overwrite existing installation?',
        defaultValue: false,
      );
      if (!overwrite) {
        Console.info('Installation for ${agent.name} cancelled.');
        return;
      }
      await targetDir.delete(recursive: true);
    }

    // 4. Copy skill files
    Console.step(1, 2, 'Copying skill files...');
    await FileUtils.copyDirectory(Directory(skillSource), targetDir);

    // 5. Register in AGENTS.md
    Console.step(2, 2, 'Registering skill in AGENTS.md...');
    await _registerInAgentsMd(projectDir, targetPath);

    Console.success(
      'Air Framework skill installed for ${agent.name} at:\n  $targetPath',
    );
    print('');
  }

  /// Writes or appends the skill reference to AGENTS.md in the project root.
  ///
  /// If the file doesn't exist it is created with a minimal header.
  /// If the reference is already present, it is skipped.
  Future<void> _registerInAgentsMd(String projectDir, String skillPath) async {
    final agentsMdFile = File(path.join(projectDir, 'AGENTS.md'));

    // Relative path looks cleaner in the markdown
    final relativeSkillPath = path.relative(skillPath, from: projectDir);

    final reference =
        'Use [air_framework]($relativeSkillPath) for Flutter module development, '
        'state management (Flows/Pulses), dependency injection (AirDI), '
        'routing, CLI scaffolding, and all Air Framework patterns.';

    if (agentsMdFile.existsSync()) {
      final content = await agentsMdFile.readAsString();

      // Avoid duplicate entries
      if (content.contains(relativeSkillPath)) {
        Console.info(
          'AGENTS.md already references the skill at $relativeSkillPath.',
        );
        return;
      }

      // Append to existing file
      await agentsMdFile.writeAsString('${content.trimRight()}\n$reference\n');
      Console.success('Added skill reference to existing AGENTS.md');
    } else {
      // Create a new AGENTS.md with the reference
      await agentsMdFile.writeAsString('# Agent Guidelines\n\n$reference\n');
      Console.success('Created AGENTS.md with skill reference');
    }
  }

  /// Resolves the path to the bundled skill assets.
  ///
  /// Strategy (in order):
  ///   1. Next to the script when running with `dart run bin/air.dart` (dev mode)
  ///   2. Relative to `Platform.script` in pub global snapshots
  String? _resolveSkillSourceDir() {
    final scriptUri = Platform.script;

    // The assets folder is always at <package-root>/assets/skills/air_framework
    // We walk up from the script location to find the package root.
    // In dev: script = .../air-cli/bin/air.dart  → up 2 = air-cli/
    // In pub global: script = .../snapshots/air.dart.snapshot → check parent dirs

    Directory? scriptDir = File.fromUri(scriptUri).parent;
    for (var i = 0; i < 5; i++) {
      final candidate = path.join(
        scriptDir!.path,
        'assets',
        'skills',
        'air_framework',
      );
      if (Directory(candidate).existsSync()) return candidate;
      if (scriptDir.parent.path == scriptDir.path) break; // filesystem root
      scriptDir = scriptDir.parent;
    }

    // Fallback: check next to the executable name resolved from PATH
    final execDir = File(Platform.resolvedExecutable).parent;
    final execCandidate = path.join(
      execDir.path,
      'assets',
      'skills',
      'air_framework',
    );
    if (Directory(execCandidate).existsSync()) return execCandidate;

    return null;
  }
}

class AgentInfo {
  final String name;
  final String skillPath;

  AgentInfo(this.name, this.skillPath);
}
