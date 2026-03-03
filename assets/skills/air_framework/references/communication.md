# Cross-Module Communication Reference

Air Framework provides two communication mechanisms:
1. **TypedEvents** — strongly-typed events for known interactions
2. **Named Signals** — string-key events for loose coupling

Both go through `EventBus`, which is available via `air_framework`.

---

## Typed Events

Best for: modules that know each other's event contracts.

### Define an Event

```dart
import 'package:air_framework/air_framework.dart';

class ProductSelectedEvent extends ModuleEvent {
  final Product product;

  ProductSelectedEvent({
    required super.sourceModuleId,
    required this.product,
  });
}
```

### Emit

```dart
EventBus().emit(
  ProductSelectedEvent(sourceModuleId: 'products', product: selectedProduct),
);
```

### Listen

```dart
// Typically in onInit of the receiving module
EventBus().on<ProductSelectedEvent>(
  (event) {
    // event.product is already typed
    cartState.addItem(event.product);
  },
  subscriberModuleId: 'cart',
);
```

---

## Named Signals (Loose Coupling)

Best for: UI events, notifications, or when modules shouldn't import each other's types.

### Emit a Signal

```dart
EventBus().emitSignal(
  'cart.item_added',
  data: {'productId': '123', 'qty': 1},
  sourceModuleId: 'products',
);
```

### Listen to a Signal

```dart
EventBus().onSignal(
  'cart.item_added',
  (data) {
    // data is dynamic — cast as needed
    final map = data as Map<String, dynamic>;
    badgeCount++;
  },
  subscriberModuleId: 'header',
);
```

---

## Air.pulse — Low-level Event Dispatch

For framework-level events or cross-cutting concerns:

```dart
Air().pulse(
  action: 'logout',
  params: {'reason': 'session_expired'},
  sourceModuleId: 'auth',
  onSuccess: () => print('handled'),
  onError: (err) => print('error: $err'),
);
```

Listen:
```dart
Air().addActionObserver((action, data) {
  if (action == 'logout') { /* handle */ }
});
```

---

## Convention: Signal Naming

Use `module.event_name` dot notation:

```
auth.login_success
auth.logout
cart.item_added
cart.cleared
notification.received
```

---

## Avoiding Circular Dependencies

If module A listens to module B, and module B listens to module A, use **Named Signals** instead of Typed Events. Named signals don't require importing the emitter's types.
