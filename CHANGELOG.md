# Changelog


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
