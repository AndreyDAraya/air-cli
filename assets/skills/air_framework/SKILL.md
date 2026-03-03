---
name: air_framework
description: Create modular Flutter apps with the Air framework. Use this skill when building Flutter apps with modular architecture, generating modules, screens, services, or scaffolding new projects. Always use this skill when the user mentions Air Framework, AirState, AirModule, AirDI, air_framework, air_state, air_generator, air_cli, AppModule, AirView, AirBuilder, AirController, @GenerateState, Flows, Pulses, or when they want to build a new Flutter feature/module in this workspace.
---

# Air Framework Skill

A complete guide to building production-quality Flutter apps with the Air Framework — a 4-package ecosystem for modular, reactive, scalable apps.

## Packages Overview

| Package | Role |
|---|---|
| `air_framework` | Core: Modules, DI, Router, EventBus, Security, DevTools |
| `air_state` | Reactive state engine (AirController, AirView, Pulses) |
| `air_generator` | Code generation with `@GenerateState` via build_runner |
| `air-cli` | CLI scaffolding & skill management (`air create`, `air skills`) |

For in-depth reference read:
- `references/modules.md` — Module system & lifecycle
- `references/state.md` — State management (Flows, Pulses, AirView)
- `references/di.md` — Dependency injection (AirDI)
- `references/cli.md` — CLI commands & generators
- `references/communication.md` — EventBus, cross-module signals
- `references/best_practices.md` — Architecture patterns & pitfalls

---

## Quick-Start: From Zero to Running Module

### Step 1 — Scaffold (CLI)

```bash
# Create a new project
air create my_app --template=starter --org=com.example

# Add a module
air g module products --all
# Creates: lib/modules/products/ with module, state, view, service
```

### Step 2 — Define a Module

```dart
// lib/modules/products/products_module.dart
import 'package:air_framework/air_framework.dart';

class ProductsModule extends AppModule {
  @override String get id => 'products';
  @override String get name => 'Products';
  @override String get version => '1.0.0';

  @override
  List<AirRoute> get routes => [
    AirRoute(
      path: '/products',
      builder: (context, state) => const ProductsPage(),
    ),
  ];

  @override
  void onBind(AirDI di) {
    // SYNC ONLY: register everything lazily
    di.registerLazySingleton<ProductsRepository>(() => ProductsRepository());
    di.registerLazySingleton<ProductsState>(() => ProductsState());
  }

  @override
  Future<void> onInit(AirDI di) async {
    // ASYNC: initialize, load, connect
    await di.get<ProductsRepository>().init();
    di.get<ProductsState>(); // ensures state is initialized
  }

  @override
  Future<void> onDispose(AirDI di) async {
    di.unregisterModule(id);
    super.onDispose(di);
  }
}
```

### Step 3 — Define State

```dart
// lib/modules/products/ui/state/state.dart
import 'package:air_framework/air_framework.dart';
part 'state.air.g.dart';

@GenerateState('products')
class ProductsState extends _ProductsState {
  // Private fields → reactive Flows
  List<Product> _items = [];
  bool _isLoading = false;
  String? _error;

  // Public void/Future<void> methods → dispatchable Pulses
  @override
  Future<void> fetchProducts() async {
    isLoading = true;
    error = null;
    try {
      items = await AirDI().get<ProductsRepository>().getAll();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }
}
```

Then run the generator:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 4 — Build Reactive UI

```dart
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: AirView((context) {
        // AirView auto-subscribes to every Flow accessed here
        if (ProductFlows.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ProductFlows.error.value != null) {
          return Center(child: Text(ProductFlows.error.value!));
        }
        final items = ProductFlows.items.value;
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => ListTile(title: Text(items[i].name)),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ProductPulses.fetchProducts.pulse(null),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

### Step 5 — Initialize in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureAirState(); // sets up the Air State delegate

  final manager = ModuleManager();
  await manager.register(ProductsModule()); // order matters: deps first

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My App',
      routerConfig: AirRouter().router,
    );
  }
}
```

---

## Key Rules

1. **`onBind` is sync-only.** Never call `await` inside `onBind`. Use `onInit` for async setup.
2. **Register dependencies before dependents.** Module order in `main.dart` matters.
3. **Data flows down, actions flow up.** State → UI via Flows. UI → State via Pulses.
4. **One module per feature.** Modules are the unit of encapsulation.
5. **Use `AirView` for reactive UI.** Wrap any widget that reads state in `AirView` to get automatic rebuilds.
6. **Run build_runner after changing state.** Any change to `@GenerateState` classes requires regenerating code.

---

## Common Patterns

### Access DI from anywhere
```dart
final repo = AirDI().get<ProductsRepository>();
```

### Cross-module communication (EventBus)
```dart
// Emit a typed event
EventBus().emit(ProductSelectedEvent(sourceModuleId: 'products', product: p));

// Listen in another module
EventBus().on<ProductSelectedEvent>((event) {
  // handle
}, subscriberModuleId: 'cart');
```

### Navigation
```dart
context.go('/products/123');
context.push('/products/new');
```

---

## File Structure Convention

```
lib/
├── main.dart
├── app.dart
└── modules/
    └── <feature>/
        ├── <feature>_module.dart     # AppModule subclass
        ├── ui/
        │   ├── views/               # Page/screen widgets
        │   ├── widgets/             # Reusable local widgets
        │   └── state/
        │       ├── state.dart       # @GenerateState class
        │       └── state.air.g.dart # Generated (DO NOT EDIT)
        ├── services/                # Business logic
        ├── repositories/            # Data layer
        └── models/                  # Data models
```
