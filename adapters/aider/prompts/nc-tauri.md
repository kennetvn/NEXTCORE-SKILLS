---
description: Cross-platform desktop with Tauri (Rust + web UI). Use when you need small bundle (<20MB), native performance, or Electron alternatives. Tauri 2 supports mobile too.
---

# Tauri

## Tauri vs Electron

| Tauri | Electron |
|---|---|
| Bundle 2-20MB | 80-150MB |
| Rust backend | Node.js backend |
| OS-native webview (no Chromium bundled) | Chromium bundled (consistent) |
| Fast startup | Slower |
| Steeper learning curve (Rust) | Familiar (JS) |

**2026:** Choose Tauri for size-sensitive / performance-critical apps. Electron for Node-heavy backends.

## Tauri 2 also supports mobile

iOS + Android from same project. Still maturing but promising for light cross-platform.

## Setup

```bash
npm create tauri-app@latest
# Choose: React/Vue/Svelte/vanilla + TypeScript
cd my-app
npm run tauri dev
```

Structure:
```
src/              # frontend (React/Vue/Svelte)
src-tauri/        # Rust backend
  src/main.rs
  tauri.conf.json
  Cargo.toml
```

## Rust commands (callable from frontend)

```rust
// src-tauri/src/main.rs
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet])
        .run(tauri::generate_context!())
        .expect("error");
}
```

```ts
// frontend
import { invoke } from "@tauri-apps/api/core";
const msg = await invoke<string>("greet", { name: "Hao" });
```

## Async Rust commands

```rust
#[tauri::command]
async fn fetch_data(url: String) -> Result<serde_json::Value, String> {
    let response = reqwest::get(&url).await.map_err(|e| e.to_string())?;
    response.json().await.map_err(|e| e.to_string())
}
```

## Permissions (Tauri 2 capability model)

```json
// src-tauri/capabilities/main.json
{
  "identifier": "main-capability",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "fs:allow-read-text-file",
    "fs:allow-write-text-file"
  ]
}
```

Explicit permissions per window — secure by default.

## File system access

```ts
import { readTextFile, writeTextFile } from "@tauri-apps/plugin-fs";

const content = await readTextFile("/path/to/file.txt");
await writeTextFile("/path/output.txt", "content");
```

## Events

```rust
// Rust emits
app_handle.emit("progress", 50).unwrap();
```

```ts
// JS listens
import { listen } from "@tauri-apps/api/event";
await listen<number>("progress", (e) => console.log(e.payload));
```

## Packaging

```bash
npm run tauri build
```

Outputs:
- Windows: MSI installer, NSIS
- macOS: DMG, .app
- Linux: AppImage, deb, rpm

Sign macOS: `TAURI_SIGNING_PRIVATE_KEY` env + Apple Developer cert.

## Auto-update

```json
// tauri.conf.json
"plugins": {
  "updater": {
    "endpoints": ["https://cdn.example.com/updates/{{target}}/{{current_version}}"],
    "pubkey": "..."
  }
}
```

## Anti-patterns

- Heavy business logic in frontend (defeats Rust performance advantage)
- Ignoring permissions (allow-everything = insecure)
- Shipping debug builds (large + slow)
- Using `tauri::Builder::default()` without error handling
- No code signing for distribution (macOS Gatekeeper blocks)

## Integration

- `nc-auth-patterns` — keyring/keytar equivalent via `tauri-plugin-stronghold`
- `nc-observability` — Sentry Rust SDK in backend, browser SDK in frontend
- `nc-ci-cd` — Tauri Action for cross-platform builds in GitHub Actions
