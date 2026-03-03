# Adapters Reference

## What is an Adapter?

An **Adapter** is a headless service integration for the Air Framework. Unlike modules, adapters have **no routes, no UI, no icon** — they only register infrastructure services (HTTP, error tracking, analytics, etc.) in `AirDI`.

| Aspect | Module (`AppModule`) | Adapter (`AirAdapter`) |
|---|---|---|
| Purpose | Feature (UI + logic) | Infrastructure service |
| Has routes? | ✅ Yes | ❌ No |
| Has UI? | ✅ Yes | ❌ No |
| Registered via | `ModuleManager` | `AdapterManager` |
| Boot order | After adapters | — |

## AirAdapter — Base Class

```dart
class SentryAdapter extends AirAdapter {
  // REQUIRED
  @override String get id => 'sentry';

  // RECOMMENDED
  @override String get name => 'Sentry';
  @override String get version => '1.0.0';

  // ── Lifecycle (same as AppModule but without routes) ──

  @override
  void onBind(AirDI di) {
    super.onBind(di);
    // Register the ABSTRACT CONTRACT, not the concrete class
    di.registerLazySingleton<ErrorReporter>(() => SentryReporter());
  }

  @override
  Future<void> onDispose(AirDI di) async {
    // Clean up resources
    super.onDispose(di);
  }
}
```

## AdapterManager — Registration

Adapters MUST be registered **BEFORE** modules so that modules can depend on adapter-provided services.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureAirState();

  // 1. Adapters (infrastructure) — FIRST
  final adapters = AdapterManager();
  await adapters.register(DioAdapter(baseUrl: 'https://api.example.com'));
  await adapters.register(SentryAdapter(dsn: 'https://...'));

  // 2. Modules (features) — SECOND
  final manager = ModuleManager();
  await manager.register(AuthModule());      // can use HttpClient
  await manager.register(ProductsModule());  // can use HttpClient
  await manager.register(ShellModule());

  runApp(const MyApp());
}
```

## Boot Order

```
AdapterManager.register(adapter)
  → adapter.onBind(di)    // register contracts in DI
  → adapter.onInit(di)    // async setup
  // Adapter is now ACTIVE

ModuleManager.register(module)
  → module.onBind(di)     // can use di.get<HttpClient>() ✅
  → module.onInit(di)
```

## The Contract Rule ⭐

**Every adapter MUST have an abstract contract.** This is the core best practice.

```dart
// ❌ BAD — modules depend on Dio directly
di.registerSingleton<Dio>(dio);

// ✅ GOOD — modules depend on abstract HttpClient
di.registerLazySingleton<HttpClient>(() => DioHttpClient(dio));
```

Why? Because modules should never know what library is behind the contract. You can swap Dio for `http` or any other library without touching a single module.

## Adapter Directory Structure

```
lib/adapters/<name>/
├── contracts/                    # ⭐ REQUIRED
│   ├── <name>_client.dart        # Abstract interface
│   └── <name>_response.dart      # Response wrapper (if needed)
├── <name>_adapter.dart           # AirAdapter subclass
└── <name>_impl.dart              # Concrete implementation
```

Generate with CLI:
```bash
air g adapter sentry
```

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Folder | `adapters/<name>/` | `adapters/dio/`, `adapters/sentry/` |
| Contract | `<Name>Client` | `HttpClient`, `ErrorReporter` |
| Implementation | `<Name>ClientImpl` or `<Lib><Name>Client` | `DioHttpClient`, `SentryReporter` |
| Adapter class | `<Name>Adapter` | `DioAdapter`, `SentryAdapter` |
| Response | `<Name>Response` | `HttpResponse`, `SentryResponse` |

## Using Adapter Services in Modules

Modules depend on the **contract**, never on the implementation:

```dart
class ProductsModule extends AppModule {
  @override
  void onBind(AirDI di) {
    // HttpClient is provided by DioAdapter — this module doesn't know about Dio
    di.registerLazySingleton<ProductService>(
      () => ProductService(di.get<HttpClient>()),
    );
  }
}
```

```dart
class ProductService {
  final HttpClient _http; // abstract — no Dio import needed

  ProductService(this._http);

  Future<List<Product>> getAll() async {
    final response = await _http.get('/products');
    return (response.data as List).map((j) => Product.fromJson(j)).toList();
  }
}
```

## DevTools

Registered adapters appear in the **ADAPTERS** tab of the Air DevTools inspector, showing their id, name, version, and state.

## Common Adapter Examples

| Adapter | Contract | Library |
|---|---|---|
| `DioAdapter` | `HttpClient` | `dio` |
| `SentryAdapter` | `ErrorReporter` | `sentry_flutter` |
| `HiveAdapter` | `StorageClient` | `hive` |
| `FirebaseAdapter` | `AnalyticsClient` | `firebase_analytics` |
| `StripeAdapter` | `PaymentClient` | `stripe_sdk` |
