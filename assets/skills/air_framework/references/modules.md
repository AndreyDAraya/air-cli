# Module System Reference

## AppModule — Base Class

Every feature is a module. Extend `AppModule` and override the relevant hooks:

```dart
class MyModule extends AppModule {
  // REQUIRED
  @override String get id => 'my_module';    // unique identifier

  // RECOMMENDED
  @override String get name => 'My Module';
  @override String get version => '1.0.0';
  @override String get initialRoute => '/my';

  // Declare version-pinned dependencies on other modules
  @override List<String> get dependencies => ['auth:^1.0.0'];

  // ── Lifecycle ──────────────────────────────────────────

  // SYNC: register DI bindings here (no await)
  // @mustCallSuper — always call super.onBind(di) first
  @override
  void onBind(AirDI di) {
    super.onBind(di);
    di.registerLazySingleton<MyService>(() => MyService(), moduleId: id);
    di.registerLazySingleton<MyState>(() => MyState(), moduleId: id);
  }

  // ASYNC: heavy initialization (DB, network, file I/O)
  // @mustCallSuper — always await super.onInit(di) first
  @override
  Future<void> onInit(AirDI di) async {
    await super.onInit(di);
    await di.get<MyService>().initialize();
    di.get<MyState>(); // trigger lazy init
  }

  // CLEANUP: called when module is unregistered
  // @mustCallSuper — always call super.onDispose(di) last
  @override
  Future<void> onDispose(AirDI di) async {
    di.unregisterModule(id);
    super.onDispose(di);
  }

  // ── Routes ─────────────────────────────────────────────

  @override
  List<AirRoute> get routes => [
    AirRoute(
      path: '/my',
      builder: (context, state) => const MyPage(),
    ),
    // Path parameter
    AirRoute(
      path: '/my/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return MyDetailPage(id: id);
      },
    ),
    // Shell route (persistent navigation UI)
    AirRoute(
      path: '/shell',
      isShellRoute: true,
      builder: (context, state) => const ShellPage(),
      routes: [
        AirRoute(path: '/home', builder: (_, __) => const HomePage()),
      ],
    ),
  ];
}
```

## ModuleManager — Registration

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureAirState();

  final manager = ModuleManager();

  // Register in dependency order (dependencies first!)
  await manager.register(AuthModule());
  await manager.register(ProductsModule());  // may depend on auth
  await manager.register(ShellModule());     // navigation shell last

  runApp(const App());
}
```

## AirRouter — Routing

`AirRouter` collects routes from all registered modules automatically.

```dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AirRouter().router,
    );
  }
}
```

Navigation uses `go_router` under the hood:
```dart
context.go('/products');
context.push('/products/new');
context.pop();
context.goNamed('product-detail', pathParameters: {'id': '123'});
```

## Module Lifecycle Sequence

```
ModuleManager.register(module)
  → module.onBind(di)   // sync DI setup
  → module.onInit(di)   // async init
  // Module is now ACTIVE

ModuleManager.unregister(module)
  → module.onDispose(di) // cleanup
```

## Module Directory Conventions

```
lib/modules/<feature>/
├── <feature>_module.dart      # AppModule subclass
├── ui/
│   ├── views/                 # Full-page widgets
│   ├── widgets/               # Local reusable components
│   └── state/
│       ├── state.dart         # @GenerateState class
│       └── state.air.g.dart   # Generated (don't edit)
├── services/                  # Business logic / API
├── repositories/              # Data access layer
└── models/                    # Pure data classes
```
