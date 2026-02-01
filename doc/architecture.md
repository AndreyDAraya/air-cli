# Architecture & Structure

The Air Framework generates a project structure designed effectively for modularity and scalability.

## Project Structure

When you create a new project, you get the following structure:

```text
my_project/
├── lib/
│   ├── modules/          # Feature modules
│   ├── main.dart         # Entry point
│   └── app.dart          # App configuration
├── pubspec.yaml          # Dependencies
└── ...
```

### `lib/modules/`

This is where the magic happens. All features of your application should be encapsulated within modules in this directory.

Each module is self-contained and exposes its functionality through a defined interface.

### `lib/main.dart`

The entry point of the application. It typically initializes the `AirManager` modules.

### `lib/app.dart`

Contains the root widget of your application (usually `MaterialApp` or `CupertinoApp`) and sets up the router with the modules.

## Design Patterns

### Modular Monolith

Air Framework encourages a modular monolith architecture. You build features as if they were separate micro-apps (modules) but deploy them as a single monolithic application.

Benefits:

- **Separation of Concerns**: Each module handles one specific domain.
- **Scalability**: New teams can work on new modules without conflicting with others.
- **Reusability**: Modules can be extracted and shared across projects.

### State Management (Air State)

The framework uses valid a specific pattern for state management:

- **State**: The controller logic.
- **Pulses**: Events/Actions triggered by the UI.
- **Flows**: Data streams observed by the UI.

This ensures a unidirectional data flow and clear separation between UI and Logic.
