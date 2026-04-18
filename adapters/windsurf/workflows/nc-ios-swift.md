---
description: Native iOS development with Swift + SwiftUI. Use when building iOS-only apps, need deep platform integration, App Store submission, or SwiftUI/UIKit architecture decisions.
auto_execution_mode: 1
---

# iOS (Swift)

## SwiftUI vs UIKit

SwiftUI (2026 default): declarative, less boilerplate, hot reload via Xcode Previews.  
UIKit: mature, all custom controls work, needed for legacy apps.

**Start SwiftUI**, drop to UIKit via `UIViewRepresentable` for specific controls (maps, AVKit).

## SwiftUI basics

```swift
import SwiftUI

struct CounterView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.largeTitle)
            Button("Increment") {
                count += 1
            }
        }
    }
}
```

## State management

- `@State` — local view state
- `@StateObject` — owns `ObservableObject` lifecycle
- `@ObservedObject` — subscribes to external `ObservableObject`
- `@EnvironmentObject` — inherit from ancestor
- `@Bindable` (iOS 17+) — two-way binding

### Observation (iOS 17+ macro)

```swift
@Observable
class UserStore {
    var currentUser: User?

    func login(_ user: User) {
        currentUser = user
    }
}
```

Simpler than ObservableObject — any property auto-publishes.

## Navigation (iOS 16+)

```swift
NavigationStack(path: $path) {
    HomeView()
        .navigationDestination(for: User.self) { user in
            UserDetailView(user: user)
        }
}
```

## Networking

```swift
struct User: Codable { let id: Int; let email: String }

func fetchUser(_ id: Int) async throws -> User {
    let url = URL(string: "https://api.example.com/users/\(id)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}

// In view
.task {
    user = try? await fetchUser(42)
}
```

## Concurrency (Swift 6 strict)

- `async/await` for all async work
- `Task {}` for fire-and-forget from sync context
- `@MainActor` for UI-updating code
- `Sendable` for cross-actor types
- Avoid `DispatchQueue.main.async` in new code

## Persistence

| Option | When |
|---|---|
| UserDefaults | Small settings (theme, flags) |
| Core Data | Relational, complex queries |
| SwiftData (iOS 17+) | Modern Core Data wrapper, @Model macro |
| Realm / GRDB | Large data, cross-platform sync |
| Keychain | Tokens, passwords |

## App Store submission

1. Xcode → Archive → Distribute App
2. App Store Connect → metadata, screenshots, pricing
3. Submit for review (1-3 day wait)
4. TestFlight for beta (no review for internal testers)

## Testing

- `XCTest` — unit + UI
- `Swift Testing` framework (Xcode 16+) — modern syntax

```swift
import Testing

@Test func counter() {
    let c = Counter()
    c.increment()
    #expect(c.value == 1)
}
```

## Anti-patterns

- Blocking main thread with sync I/O
- Force unwrapping (`!`) in production (crash risk)
- Massive view files (split into small views)
- Ignoring memory (reference cycles in closures — use `[weak self]`)
- Starting in UIKit for new projects (SwiftUI is the future)

## Integration

- `nc-auth-patterns` — Keychain for token storage
- `nc-api-contracts` — OpenAPI → Swift client via openapi-generator
- `nc-observability` — Sentry iOS SDK
