# Best Practices & Common Pitfalls

## Architecture Principles

### 1. One Module Per Feature
```
✅ lib/modules/auth/
✅ lib/modules/products/
✅ lib/modules/cart/

❌ lib/modules/app/  (too broad)
```

### 2. Unidirectional Data Flow
```
User Action
  → Pulse (e.g. ProductPulses.fetchProducts(null))
    → State Method (e.g. fetchProducts())
      → Flow Update (e.g. items = newItems)
        → UI Rebuild (AirView detects change)
```
Never drive state from the UI widget's lifecycle. Keep logic in State.

### 3. onBind is Sync-Only
```dart
// ✅ Correct
@override
void onBind(AirDI di) {
  di.registerLazySingleton<MyService>(() => MyService());
}

// ❌ Wrong — never use await inside onBind
@override
void onBind(AirDI di) {
  di.registerSingleton<MyService>(await MyService.create()); // crash!
}
```

### 4. Register Modules in Dependency Order
```dart
await manager.register(AuthModule());       // no deps
await manager.register(ProductsModule());   // depends on auth
await manager.register(CartModule());       // depends on products
await manager.register(ShellModule());      // navigation wrapper last
```

### 5. Always Pass moduleId to DI Registrations
```dart
// ✅ Enables automatic cleanup in onDispose
di.registerLazySingleton<ProductsRepo>(() => ProductsRepo(), moduleId: id);

// ❌ Can't be cleaned up by unregisterModule
di.registerLazySingleton<ProductsRepo>(() => ProductsRepo());
```

---

## State Patterns

### Loading + Error Pattern
```dart
@GenerateState('products')
class ProductsState extends _ProductsState {
  List<Product> _items = [];
  bool _isLoading = false;
  String? _error;

  @override
  Future<void> fetch() async {
    isLoading = true;
    error = null;
    try {
      items = await _repo.fetchAll();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;  // always reset loading
    }
  }
}
```

### Reading State Efficiently
```dart
// ✅ Use AirView when multiple flows are needed
AirView((context) {
  if (ProductFlows.isLoading.value) return const Loader();
  return ProductList(items: ProductFlows.items.value);
});

// ✅ Use AirBuilder for single-key widgets
AirBuilder<bool>(
  stateKey: 'products.isLoading',
  initialValue: false,
  builder: (_, loading) => loading ? const Loader() : const SizedBox(),
);

// ✅ Use TypedStateKey for simple global state
const badgeCountKey = SimpleStateKey<int>('cart.badge', defaultValue: 0);
badgeCountKey.build((context, count) => Badge(label: Text('$count')));
```

---

## Testing Patterns

### Mock DI in Widget Tests
```dart
setUp(() {
  AirDI().clear();
  AirDI().register<ProductsRepository>(
    MockProductsRepository(),
    allowOverwrite: true,
  );
  Air().reset(); // reset state
  configureAirState();
});
```

### Test State in Isolation
```dart
test('fetch updates items', () async {
  Air().reset();
  configureAirState();
  
  final state = ProductsState();
  expect(ProductFlows.items.value, isEmpty);
  
  await state.fetch();
  
  expect(ProductFlows.items.value, isNotEmpty);
});
```

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| `AirView` not rebuilding | Missing `.value` access inside the builder |
| Build errors in state file | Run `dart run build_runner build --delete-conflicting-outputs` |
| DI dependency not found | Add `await manager.register(DependencyModule())` before dependents |
| State readable but stale | Use `forceNotify()` after in-place mutations (e.g., `list.add()`) |
| Module disposing too early | Call `di.unregisterModule(id)` in `onDispose`, not `onBind` |
| Navigation not working | Ensure `MaterialApp.router(routerConfig: AirRouter().router)` is used |

---

## Performance Tips

1. **Keep AirView builders lean** — only access the flows you need to minimize rebuilds.
2. **Use `AirBuilder` over `AirView` for single-key subscriptions** — less overhead.
3. **Register as LazySingleton, not Singleton** — services instantiate only when first needed.
4. **Prefer `setValue(silent: true)` for bulk updates** — batch multiple updates then call `notifyListeners()` once.
