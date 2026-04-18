---
name: nc:react-native
description: "Cross-platform mobile development with React Native. Use when building iOS+Android from single codebase, evaluating Expo vs bare workflow, native module integration, or performance optimization."
license: MIT
argument-hint: "[setup|expo|bare|navigation|native-module|perf]"
---

# React Native

## Expo vs bare workflow

| Expo (managed) | Bare workflow |
|---|---|
| Fast start, OTA updates | Full native control |
| Limited native modules | Any native module |
| EAS Build handles signing | Manual Xcode / Android Studio |
| Good for MVPs, most apps | Needed for complex native needs |

**2026 recommendation:** Expo for new projects. Eject only if you need a native module Expo doesn't support.

## Navigation

```tsx
// React Navigation v7+
import { createNativeStackNavigator } from "@react-navigation/native-stack";

const Stack = createNativeStackNavigator();

<Stack.Navigator>
  <Stack.Screen name="Home" component={HomeScreen} />
  <Stack.Screen name="Details" component={DetailsScreen} />
</Stack.Navigator>
```

Or **Expo Router** (file-based, like Next.js):

```
app/
  _layout.tsx
  index.tsx        → /
  settings.tsx     → /settings
  [id].tsx         → /:id
```

## State + data

Same as web — TanStack Query for server state, Zustand for client state. Avoid AsyncStorage-only solutions (slow, no query invalidation).

## Native modules

```ts
// Call native code from JS
import { NativeModules } from "react-native";
const { MyNativeModule } = NativeModules;
MyNativeModule.doSomething("arg").then(result => ...);
```

For iOS: Objective-C/Swift. For Android: Java/Kotlin. Or use **Turbo Modules** (new arch) for type-safe bridging.

## Performance

- **FlatList** over ScrollView for long lists (virtualized)
- **useMemo**/`React.memo` aggressively — RN re-renders expensive
- **Hermes** engine (default in RN 0.76+)
- **Image**: use `expo-image` or `react-native-fast-image` (caching)
- **Startup**: lazy-load non-critical screens
- **Profiling**: Flipper (deprecated, use native tools) or React DevTools Profiler

## Forms + input

- `react-hook-form` + `zod`
- `KeyboardAvoidingView` (or `react-native-keyboard-controller` for advanced)
- Focus management with `TextInput refs`

## Styling

- StyleSheet.create (built-in)
- **NativeWind** — Tailwind-like for RN
- **Tamagui** — design system + themes, universal web+native
- Avoid inline styles in render-heavy components

## Deployment

### Expo (EAS)

```bash
eas build --platform ios
eas build --platform android
eas submit --platform ios     # App Store Connect
eas submit --platform android # Play Console
eas update                    # OTA hot fix
```

### Bare

- iOS: Fastlane + Xcode Cloud or CI
- Android: Gradle + Play Console API

## Testing

- **Unit**: Jest + React Native Testing Library
- **E2E**: Detox (iOS/Android) or Maestro (declarative, easier)

## Anti-patterns

- Using ScrollView for 100+ items (use FlatList)
- Inline object styles (new object every render)
- No memoization in Context provider (re-render storm)
- OTA updating native code changes (must rebuild)
- Ignoring iOS/Android platform differences (test both)

## Integration

- `nc-state-management` — same patterns apply
- `nc-auth-patterns` — secure token storage (Keychain/Keystore via expo-secure-store)
- `nc-api-contracts` — generate TS client from OpenAPI for strong types
