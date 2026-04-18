---
description: Cross-platform mobile + desktop + web with Flutter/Dart. Use when building iOS+Android+Web from single codebase, evaluating Flutter vs React Native, state management (Riverpod/BLoC), or platform channels.
auto_execution_mode: 1
---

# Flutter

## When Flutter

- Need pixel-perfect UI consistency across iOS/Android/Web/Desktop
- Heavy custom UI (Flutter renders its own widgets, not platform-native)
- Team comfortable with Dart

When NOT: Dev team TypeScript-only, iOS-native feel required, web is primary.

## Project setup

```bash
flutter create my_app
cd my_app
flutter run                    # dev (connected device/emulator)
flutter build apk              # Android
flutter build ios              # iOS (macOS only)
flutter build web              # web
```

## State management (2026 recommendation)

### Riverpod (most popular)

```dart
final counterProvider = StateProvider<int>((ref) => 0);

class Counter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return TextButton(
      onPressed: () => ref.read(counterProvider.notifier).state++,
      child: Text('$count'),
    );
  }
}
```

### BLoC (enterprise, complex apps)

Reactive streams + events + states. Heavier boilerplate, better for large teams.

### Provider (built-in, simple)

```dart
ChangeNotifierProvider(
  create: (_) => CartModel(),
  child: MaterialApp(...),
)
```

## Navigation

### go_router (declarative)

```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomeScreen()),
    GoRoute(path: '/details/:id', builder: (_, state) => DetailsScreen(id: state.pathParameters['id']!)),
  ],
);

MaterialApp.router(routerConfig: router);
```

## Platform channels (call native code)

```dart
// Dart side
static const platform = MethodChannel('com.example.app/battery');
final level = await platform.invokeMethod<int>('getBatteryLevel');

// Android (Kotlin)
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.app/battery")
  .setMethodCallHandler { call, result ->
    if (call.method == "getBatteryLevel") result.success(85)
  }
```

## Forms

```dart
final _formKey = GlobalKey<FormState>();
Form(
  key: _formKey,
  child: TextFormField(
    validator: (v) => v?.isEmpty == true ? 'Required' : null,
  ),
)

if (_formKey.currentState!.validate()) { /* submit */ }
```

## Networking

- **http** package (simple)
- **dio** (interceptors, retry, cancel)
- **retrofit** (code-gen from OpenAPI)

## Testing

- Unit: `test` package
- Widget: `flutter_test`
- Integration: `integration_test` + `patrol` (more expressive)

## Performance

- `const` constructors everywhere possible (skip rebuild)
- `ListView.builder` for long lists (lazy)
- `RepaintBoundary` for expensive static widgets
- `flutter run --profile` to profile realistically

## Anti-patterns

- `setState` in `build()` (infinite loop)
- Non-const widgets inside constant contexts (missed optimization)
- Global mutable state (use Riverpod)
- Ignoring `dispose()` on controllers/streams (memory leak)

## Integration

- `nc-state-management` — Riverpod/BLoC equivalent to Zustand/Redux
- `nc-api-contracts` — OpenAPI → dart client via `openapi-generator`
- `nc-auth-patterns` — flutter_secure_storage for tokens
