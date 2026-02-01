# Module System

The Module System is the core of the Air Framework. It allows you to encapsulate features, logic, and UI into reusable units.

## Module Structure

When you generate a module (e.g., `air generate module cart --all`), the CLI creates the following structure:

```text
lib/modules/cart/
├── cart_module.dart       # Module definition & configuration
├── models/                # Data models
├── services/              # Business logic services
└── ui/
    ├── views/             # UI Screens/Pages
    │   └── cart_page.dart
    └── state/             # State Management
        ├── cart_state.dart
        ├── cart_pulses.dart
        └── cart_flows.dart
```

### 1. Module Definition (`*_module.dart`)

Every module has a main entry file that implements `AppModule`. This file defines:

- **Metadata**: Name, ID, Version, Icon, Color.
- **Routing**: The routes exposed by this module.
- **Dependencies**: Dependency injection setup (`onBind`).
- **Initialization**: Async initialization logic (`initialize`).

```dart
class CartModule implements AppModule {
  @override
  String get id => 'cart';

  @override
  List<AirRoute> get routes => [
    AirRoute(path: '/cart', builder: (_) => const CartPage()),
  ];

  // ...
}
```

### 2. UI Views (`ui/views/`)

Contains the Flutter widgets that form the visual part of your module. The CLI generates a default page for you.

### 3. State Management (`ui/state/`)

If generated with `--all`, the module includes:

- **`*_state.dart`**: The logic controller. Extends `AirState`.
- **`*_pulses.dart`**: Defines actions (Pulses) the UI can trigger.
- **`*_flows.dart`**: Defines data streams (Flows) the UI can listen to.

### 4. Services (`services/`)

Pure Dart classes that handle business logic, API calls, or database interactions. These should be decoupled from the framework UI code.

### 5. Models (`models/`)

Data classes (POJOs) used within the module.

## Registering a Module

To use a module, you must register it in your application's `AirManager` (usually in `main.dart`):

```dart
void main() {
  final manager = AirManager();

  manager.register(CartModule());
  // ...

  runApp(MyApp(manager: manager));
}
```

## Sharing Modules

Because modules are self-contained, you can easily share them:

1.  Push module code to a Git repository.
2.  Import it in another project using `air module add`.
