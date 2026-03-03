# Dependency Injection Reference (AirDI)

`AirDI` is a global singleton service locator for the Air Framework.

## Registration Methods

### Singleton (immediate)
Registers an already-constructed instance. Same instance returned every time.

```dart
di.register<MyService>(MyServiceImpl()); // alias for registerSingleton
di.registerSingleton<MyService>(MyServiceImpl());
```

### Lazy Singleton
Factory runs only on first `get<T>()` call. Same instance returned on subsequent calls.

```dart
di.registerLazySingleton<MyService>(() => MyServiceImpl());
```
**Use this in `onBind`.** Heavy objects are created only when needed.

### Factory
A new instance is created on every `get<T>()` call.

```dart
di.registerFactory<MyViewModel>(() => MyViewModel());
```

## Retrieving Dependencies

```dart
// Throws DependencyNotFoundException if not registered
final service = AirDI().get<MyService>();

// Returns null instead of throwing
final service = AirDI().tryGet<MyService>();

// Check before getting
if (AirDI().isRegistered<MyService>()) { ... }
```

### Retrieval Shorthand (Preferred in States)

Inside any class annotated with `@GenerateState`, you can use the `inject<T>()` shorthand:

```dart
final service = inject<MyService>();
```

## Ownership & Cleanup

Every registration can be tagged with a `moduleId`:

```dart
di.registerLazySingleton<MyService>(
  () => MyServiceImpl(),
  moduleId: 'products', // ownership
);
```

This enables module-scoped cleanup:

```dart
// In onDispose:
di.unregisterModule('products'); // removes all 'products' registrations
```

## Overwrite Protection

By default, re-registering the same type throws `DependencyAlreadyRegisteredException`.
To override (e.g., in tests):

```dart
di.registerSingleton<MyService>(MockService(), allowOverwrite: true);
```

## Testing Utilities

```dart
// In test setUp:
AirDI().clear(); // only works in kDebugMode
AirDI().register<MyService>(MockService(), allowOverwrite: true);
```

## Common Mistakes

| Mistake | Fix |
|---|---|
| `await di.get<T>()` inside `onBind` | Move async init to `onInit` |
| Forgetting `moduleId` on registration | Add `moduleId: id` so cleanup works |
| Getting a service before registering its module | Register dependency modules first in `main.dart` |
