---
name: nc:state-management
description: "Frontend state management patterns: Zustand, Jotai, TanStack Store, Redux, React Context. Use when choosing a state library, refactoring prop-drilling, or architecting a React app."
license: MIT
argument-hint: "[zustand|jotai|tanstack|redux|context]"
---

# State Management

## Decision tree

```
Is it server state (from API)?
  → TanStack Query / SWR (don't use global store)

Is it URL state?
  → useSearchParams / nuqs (URL is truth)

Is it form state?
  → react-hook-form / TanStack Form

Is it UI state (modals, theme)?
  → React Context (small) or Zustand (growing)

Is it complex domain state?
  → Zustand / Jotai (simple) or Redux Toolkit (complex, time-travel debug)
```

## Zustand (recommended default)

Minimal boilerplate, works outside React, great DX:

```ts
import { create } from "zustand";

interface CartStore {
  items: Item[];
  add: (item: Item) => void;
  remove: (id: string) => void;
  total: () => number;
}

export const useCart = create<CartStore>((set, get) => ({
  items: [],
  add: (item) => set((s) => ({ items: [...s.items, item] })),
  remove: (id) => set((s) => ({ items: s.items.filter(i => i.id !== id) })),
  total: () => get().items.reduce((sum, i) => sum + i.price, 0),
}));

// Component
const items = useCart((s) => s.items);  // subscribes to items only
const add = useCart((s) => s.add);
```

### Persist middleware

```ts
import { persist } from "zustand/middleware";

export const useCart = create(persist<CartStore>(
  (set, get) => ({ /* ... */ }),
  { name: "cart-storage" }  // localStorage
));
```

## Jotai (atomic, fine-grained)

```ts
import { atom, useAtom } from "jotai";

const countAtom = atom(0);
const doubleAtom = atom((get) => get(countAtom) * 2);

function Counter() {
  const [count, setCount] = useAtom(countAtom);
  const [double] = useAtom(doubleAtom);
  return <button onClick={() => setCount(c => c + 1)}>{count} ({double})</button>;
}
```

Best when: Fine-grained reactivity, derived state is complex.

## TanStack Store (framework-agnostic)

```ts
import { Store } from "@tanstack/store";

const store = new Store({ count: 0 });

store.setState((s) => ({ count: s.count + 1 }));
store.subscribe(() => console.log(store.state));
```

Best when: Cross-framework (React + Vue + Solid), or outside component tree.

## Redux Toolkit

```ts
import { createSlice, configureStore } from "@reduxjs/toolkit";

const cartSlice = createSlice({
  name: "cart",
  initialState: { items: [] },
  reducers: {
    add: (state, action) => { state.items.push(action.payload); },  // immer handles immutability
    remove: (state, action) => {
      state.items = state.items.filter(i => i.id !== action.payload);
    },
  },
});

export const { add, remove } = cartSlice.actions;
export const store = configureStore({ reducer: { cart: cartSlice.reducer } });
```

Best when: Large team, need Redux DevTools time-travel, complex async (createAsyncThunk), or existing Redux codebase.

## React Context (careful)

```tsx
const ThemeContext = createContext<"light" | "dark">("light");

function App() {
  const [theme, setTheme] = useState("light");
  return <ThemeContext.Provider value={theme}>...</ThemeContext.Provider>;
}
```

**Pitfall:** every context update re-renders all consumers. Split into multiple contexts or use selector pattern.

Best when: Small, rarely-changing (auth user, theme, locale).

## Server state vs client state

**Critical distinction** — don't put server data in Zustand/Redux:

```ts
// BAD — server state in global store
const users = useUsersStore((s) => s.users);  // stale, no refetch

// GOOD — TanStack Query
const { data: users } = useQuery({
  queryKey: ["users"],
  queryFn: () => api.users.list(),
});
```

TanStack Query handles: caching, background refetch, stale-while-revalidate, optimistic updates, retry, offline.

## Anti-patterns

- Global store for server data (stale, no refetch)
- Redux for small app (boilerplate overkill)
- Context for frequently-changing data (re-render storm)
- Prop drilling 5+ levels (use store)
- Mixing server + client state in same slice

## Integration

- `nc-frontend-development` — Suspense + useSuspenseQuery for async
- `nc-react-best-practices` — avoid unnecessary re-renders
- `nc-tanstack` — TanStack Query for server state
