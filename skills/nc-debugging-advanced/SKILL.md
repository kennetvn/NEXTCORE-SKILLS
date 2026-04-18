---
name: nc:debugging-advanced
description: "Debug hard problems — heisenbugs, race conditions, distributed system failures, memory corruption, intermittent prod issues. Use when nc-debug isn't enough and you need scientific-method discipline + advanced tools (gdb, strace, eBPF, distributed tracing)."
license: MIT
argument-hint: "[heisenbug|race|distributed|intermittent]"
---

# Advanced Debugging

For bugs that resist normal debugging. Discipline matters more than tools.

## The scientific method (mandatory for hard bugs)

1. **Observe** — write down EXACTLY what's happening (timestamps, symptoms, frequency)
2. **Hypothesize** — what mechanism could cause this?
3. **Predict** — if hypothesis true, X should also happen
4. **Test** — add logging / instrumentation to verify
5. **Conclude** — confirm or rule out
6. Repeat until root cause found

Don't skip step 1. Symptom drift is real — what you saw at 2am may not be what you describe at 9am.

## Heisenbugs (disappear when you look)

Bug behavior changes when you observe it.

Causes:
- Logging changes timing → race condition masked
- Debug build optimizations differ → bug only in release
- Attaching debugger pauses thread → other thread "wins" race
- printf flushes → buffering hid the issue

Tactics:
- Use ring buffer logs (cheap, in-memory) instead of stdout
- `dtrace` / `eBPF` (kernel-level, low overhead)
- Reproduce under load (stress test) — heisenbugs love idle systems
- Add tracing in branches that "can't" be reached — they often are

## Race conditions

Symptoms: works locally, fails under load. Different result each run.

Detection:
```bash
# Go: built-in race detector
go test -race ./...

# Java: ThreadSanitizer or jcstress
# C/C++: ThreadSanitizer (-fsanitize=thread), Helgrind
# Python: rare with GIL but possible (use threading.Lock audits)
# JS: single-threaded, but async race conditions are common (await ordering)
```

Common shapes:
- Check-then-act without lock (TOCTOU)
- Lazy init without synchronization
- Counter increment without atomic
- Multiple consumers reading/writing same key
- Caching with no version/etag

Fixes (in order of preference):
1. Don't share state (immutable data, message passing)
2. Use atomic primitives (compare-and-swap)
3. Mutex / RWLock (last resort, easy to deadlock)

## Distributed system failures

Hardest class of bugs. Default assumption: anything can fail at any time.

Diagnostic kit:
- **Distributed tracing** (OpenTelemetry, Jaeger, Honeycomb) — see request across services
- **Correlation IDs** — propagate through every log line
- **Wall-clock vs monotonic time** — clock skew is real
- **Network partition simulation** — `tc qdisc add dev eth0 root netem loss 5%`

Common patterns:
- Retries amplify failure (thundering herd) → exponential backoff + jitter
- Cascading timeouts (timeout < downstream timeout → orphaned work) → set deadlines, not timeouts
- Split brain (two leaders) → quorum / consensus (Raft)
- Slow node treated as healthy → end-to-end health checks

Read: Designing Data-Intensive Applications (Martin Kleppmann), Aphyr's Jepsen reports.

## Linux observability with strace / eBPF

```bash
# What syscalls does this process make?
strace -p <PID> -e trace=read,write,openat -f
strace -c -p <PID>                        # summary stats

# What files is process touching?
lsof -p <PID>

# eBPF (modern, low-overhead) — bcc-tools or bpftrace
bpftrace -e 'tracepoint:syscalls:sys_enter_openat { @[comm] = count(); }'
opensnoop                                   # who's opening files
execsnoop                                   # who's spawning processes
biolatency                                   # disk I/O latency histogram
tcptop                                       # top TCP connections
```

For containerized: run in privileged debug pod with same PID namespace.

## Memory issues

```bash
# C/C++: valgrind (catches leaks, use-after-free, OOB)
valgrind --leak-check=full --show-leak-kinds=all ./binary

# C/C++ at runtime: AddressSanitizer (faster than valgrind)
gcc -fsanitize=address -g main.c

# Java: heap dump on OOM
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp
# Analyze with Eclipse MAT

# Node.js leak detection
node --inspect app.js → Chrome DevTools Memory → 3 snapshots, compare
```

Leaks are detection-by-pattern: snapshot N, run more workload, snapshot N+M, see what grew.

## Intermittent prod-only bugs

"Happens randomly, can't reproduce locally."

Strategy:
1. Lower the cost of capturing detail when it happens (always-on lightweight tracing)
2. Capture environment delta (load, time of day, recent deploys)
3. Search logs for similar past occurrences (pattern over time)
4. Add hypothesis-testing instrumentation (don't fix yet — verify cause)
5. Reproduce in staging with prod-like load (k6, locust)

If truly unreproducible: consider canary rollback to bisect what introduced it.

## Bisecting

When a bug appeared in some version:

```bash
git bisect start
git bisect bad HEAD                 # current is bad
git bisect good v1.2.0              # last known good
# Run test → mark good/bad
git bisect good                     # or: git bisect bad
# Repeat until git pinpoints commit
git bisect reset
```

Pair with automated test → `git bisect run ./test.sh` does it for you.

## Anti-patterns

- "Try this fix" without verifying root cause (bug may return shifted)
- Adding logs everywhere → even more heisenbugs
- "Restart fixes it" as solution (delays the inevitable)
- Single-threaded reasoning about concurrent code
- Trusting wall-clock time in distributed systems
- Looking only at the failing service's logs (it's often upstream)
- Re-running test to "confirm" (flakes happen — need many runs)

## Integration

- `nc-debug` — entry-level systematic debugging
- `nc-incident-response` — debugging during prod incident
- `nc-performance-profiling` — when slow + buggy together
- `nc-observability` — distributed tracing setup
- `nc-test-strategy` — chaos / fault injection prevents bugs
- `nc-code-archaeology` — when "why was this code written" matters
