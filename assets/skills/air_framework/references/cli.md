# CLI Reference (air-cli)

Install globally once:
```bash
dart pub global activate air_cli
```

## Commands Overview

```
air <command> [arguments]

Commands:
  create <name>           Create a new Air Framework project
  generate <type> <name>  Generate components (alias: g)
  module add <source>     Add a module from Git/local path
  skills install [agent]  Install agent skill for specific AI agents
  doctor                  Check environment & project config
  version / --version     Show CLI version
  help / --help           Show help
```

## `air skills` — Agent Skill Management

Installs the Air Framework agent skill (this documentation) into your project so AI agents (Antigravity, Claude, Cursor, etc.) can understand the framework.

```bash
# Interactive selection menu
air skills install

# Specific agent installation
air skills install cursor
air skills install antigravity
air skills install claude

# Install for all supported agents at once
air skills install all
```

The command creates the appropriate directory structure for each agent (e.g., `.cursor/rules/`, `.agent/skills/`) and registers the skill in `AGENTS.md`.

## `air create` — New Project

```bash
air create my_app --template=starter --org=com.example
```

| Option | Values | Description |
|---|---|---|
| `--template` | `blank` (default), `starter` | `starter` includes auth module scaffold |
| `--org` | `com.example` | Reverse-domain org ID |

## `air generate` — Code Generators

Alias: `air g`

### Module
```bash
air g module products          # minimal module scaffold
air g module products --all    # full: module + state + screen + service
```

Creates `lib/modules/products/products_module.dart` with `AppModule` subclass.

### Screen / Page
```bash
air g screen product_detail --module=products
```
Creates a Flutter `StatelessWidget` page in `lib/modules/products/ui/views/`.

### State
```bash
air g state cart --module=products
```
Creates `@GenerateState` class + boilerplate in `lib/modules/products/ui/state/`.

### Service
```bash
air g service product_api --module=products
```
Creates a service class in `lib/modules/products/services/`.

### Model
```bash
air g model product --module=products    # inside a module
air g model currency --core              # in lib/core/models/
```

### Widget
```bash
air g widget product_card --module=products
```
Creates a reusable widget in `lib/modules/products/ui/widgets/`.

## `air module` — Module Management

```bash
# From a Git URL
air module add https://github.com/user/air_module_auth.git

# From local path
air module add /path/to/local_module

# Shortcut
air pub add https://github.com/user/air_module_auth.git
```

### Self-installable Modules (`module.yaml`)

Modules can define their own metadata and dependencies in a `module.yaml` file in their root. When using `air module add`, the CLI will automatically:
1. Identify the module name from `module.yaml`.
2. Sync dependencies listed in `module.yaml` (using `flutter pub add`).

**Example `module.yaml`:**
```yaml
name: auth_supabase
description: Authentication system with Supabase
dependencies:
  supabase_flutter: ^2.0.0
  provider: any
```

*Note: If `module.yaml` is missing, the CLI falls back to `pubspec.yaml` for dependency syncing.*

## `air doctor`

Checks:
- Flutter/Dart installation
- build_runner availability
- air_framework version compatibility
- Project structure health

## After Running Generators

Always run build_runner when `@GenerateState` classes change:

```bash
dart run build_runner build --delete-conflicting-outputs
# or watch mode:
dart run build_runner watch --delete-conflicting-outputs
```
