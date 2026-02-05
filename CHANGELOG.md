# Changelog

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
