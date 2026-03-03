# Changelog


## 1.0.6

- **Visual Identity**: Added the official Air Framework SVG logo to the README.
- **Documentation**: Updated README with the new logo and visual assets.

## 1.0.5

- **Adapter System**: Added `air generate adapter <name>` command to scaffold headless service integrations with the recommended structure (contracts, implementation, adapter).
- **Adapter Skill Documentation**: Added `references/adapters.md` with full adapter reference (lifecycle, boot order, contract rule, naming conventions, DevTools).
- **Updated Skill**: Updated `SKILL.md` with adapter keywords, quick-start, key rules (adapters before modules, contract rule), and updated file structure.
- **Updated CLI Reference**: Added adapter generator section to `references/cli.md`.

## 1.0.4

- **Air Adapters**: Introduced `AirAdapter` base class and `AdapterManager` for headless service integrations (HTTP, analytics, error tracking, etc.).
- **DevTools**: Added ADAPTERS tab to the DevTools inspector (8 tabs total).
- **Framework Exports**: Updated `core.dart` and `framework.dart` barrel exports for adapters.

## 1.0.3

- **AI Agent Selection**: Added interactive selection and "all" option to `air skills install`. Supports Antigravity, Claude Code, OpenCode, and Cursor.
- **Improved `air create`**: Added support for `air create .` to initialize projects in the current directory. Includes automatic snake_case project name derivation and sanitization.
- **Skills command**: Added `air skills install` — copies the Air Framework agent skill into `.agent/skills/air_framework/` and registers it in `AGENTS.md` so AI agents automatically know where the skill is and what it does.
- **Module Autoinstall**: The `module add` command now prefers `module.yaml` for dependency synchronization. This allows modules to define their dependencies without needing a full `pubspec.yaml`.
- **Improved Injection**: Updated skill documentation to recommend `inject<T>()` over `AirDI().get<T>()` in state classes.
- **Improved Dependency Management**: The `air create` command now fetches the latest available versions of `air_framework`, `air_generator`, and `go_router` from pub.dev.
- **Dynamic Versioning**: CLI now dynamically reads its version from `pubspec.yaml`.

## 1.0.2

- **Generator Overhaul**: Replaced the legacy 3-file state generation with a unified `@GenerateState` pattern.
- **Templates**: Updated module and screen templates to use `extends AppModule` and the latest `AirView` patterns.
- **CLI improvements**: Improved "Next steps" instructions after generation to include better dependency injection examples.

## 1.0.1

- **Reactive State Generation**: Added support for `@GenerateState` annotation with the `--generator` flag.
- **API Changes**: Updated `AppModule` interface: `onBind()` -> `onBind(AirDI di)` and `initialize()` -> `onInit(AirDI di)`.
- **Improvements**: Updated templates and generators to match the latest `air_framework` changes.

## 1.0.0

- Initial release of the Air CLI.
- **Project Generation**: Create new Air projects with `air create`.
- **Module Management**: Generate modular architecture structures with `air gen module`.
- **Code Generators**: Automate creation of Screens, States, Services, Widgets, and Models.
- **Air State Management**: Built-in support for the "Clap in the Air" state management pattern.
- **Scalable Architecture**: Enforces clean architecture and separation of concerns.
