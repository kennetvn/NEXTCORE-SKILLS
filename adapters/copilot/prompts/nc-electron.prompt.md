---
description: Cross-platform desktop apps with Electron. Use when building Windows/macOS/Linux desktop, need Node.js + web tech, or evaluating Electron vs Tauri.
mode: agent
---

# Electron

## When Electron

- Need: cross-platform desktop + web tech + Node.js APIs
- Team: React/Vue/Svelte dev
- Size OK: 80-150MB bundle per platform

When NOT: bundle size critical (use Tauri), Node.js not needed, pure native performance.

## Setup (electron-vite)

```bash
npm create @quick-start/electron my-app
```

Structure:
```
src/
  main/index.ts         # main process (Node.js)
  preload/index.ts      # bridge (secure IPC)
  renderer/             # React/Vue/Svelte app
electron-builder.yml    # packaging config
```

## Main + renderer + preload

```ts
// main/index.ts
import { app, BrowserWindow } from "electron";

app.whenReady().then(() => {
  const win = new BrowserWindow({
    width: 1200, height: 800,
    webPreferences: {
      preload: path.join(__dirname, "../preload/index.js"),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });
  win.loadURL("http://localhost:5173");  // dev
});
```

```ts
// preload/index.ts — secure bridge
import { contextBridge, ipcRenderer } from "electron";

contextBridge.exposeInMainWorld("api", {
  readFile: (path: string) => ipcRenderer.invoke("read-file", path),
});
```

```ts
// main/index.ts — handle IPC
import { ipcMain } from "electron";
ipcMain.handle("read-file", (_, path) => fs.readFile(path, "utf-8"));
```

```tsx
// renderer (React)
const content = await window.api.readFile("/path");
```

## Security rules

1. `contextIsolation: true` — always
2. `nodeIntegration: false` — never expose Node to renderer
3. Validate all IPC inputs in main process
4. Content Security Policy: `default-src 'self'`
5. Load only `file://` or HTTPS, never HTTP in production
6. Keep Electron updated (security patches)

## Auto-update

```ts
import { autoUpdater } from "electron-updater";

app.whenReady().then(() => {
  autoUpdater.checkForUpdatesAndNotify();
});
```

Host updates: GitHub Releases, S3, or electron-builder's generic provider.

## Packaging (electron-builder)

```yaml
# electron-builder.yml
appId: com.example.myapp
productName: MyApp
mac:
  category: public.app-category.productivity
  target: [dmg, zip]
win:
  target: [nsis, portable]
linux:
  target: [AppImage, deb, rpm]
publish:
  provider: github
```

```bash
electron-builder --mac --win --linux
```

## Native integration

- System tray: `new Tray(iconPath)`
- Notifications: `new Notification({ title, body }).show()`
- File system: Node `fs` (main process only)
- Menu bar: `Menu.setApplicationMenu`
- Shortcuts: `globalShortcut.register`

## Anti-patterns

- Exposing `nodeIntegration: true` (huge security hole)
- Large DOM + heavy JS → laggy compared to native
- No auto-update (users stuck on old versions)
- Bundling unused Node modules (bundle bloat)
- Running production with dev tools open (memory leak)

## Integration

- `nc-auth-patterns` — OS keychain via `keytar` library
- `nc-observability` — Sentry Electron SDK
- `nc-ci-cd` — sign + notarize macOS builds in CI (requires paid Apple Developer)
