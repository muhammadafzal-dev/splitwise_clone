# Splitwise Clone (Flutter)

A portfolio-quality, Splitwise-style expense-sharing app built **mock-first** with
a clean architecture designed so the in-memory backend can be swapped for
**Firebase (Auth + Firestore)** by changing a single wiring file — no UI or domain
changes.

> **New here? Read the docs in this order:**
> 1. [`docs/CONCEPTS.md`](docs/CONCEPTS.md) — the ideas (clean architecture, Riverpod, freezed, integer money, the split math).
> 2. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — how the layers fit and how data flows.
> 3. [`docs/BUILD_JOURNEY.md`](docs/BUILD_JOURNEY.md) — every step taken to build this, in order, with the *why*.
> 4. [`docs/FIREBASE_SETUP.md`](docs/FIREBASE_SETUP.md) — turn on the Firebase backend.

---

## What it does

- **Mock auth** — switch between demo users (stand-in for Firebase Auth).
- **Friends & groups** — create a group, add members.
- **Add expense** — payer, amount, participants, split **EQUAL / EXACT / PERCENT**, with live validation.
- **Balances** — net "who owes whom" per group *and* overall, computed by a pure, unit-tested engine.
- **Settle up** — record a payment; get suggested minimal payments.
- **Activity feed, group detail, profile** — with loading / empty / error states everywhere.
- **Material 3**, light + dark, responsive.

## Tech stack

| Concern | Choice |
|--------|--------|
| State management | Riverpod 3 |
| Routing | go_router 18 |
| Models / JSON | freezed 4 + json_serializable |
| Formatting | intl |
| IDs | uuid |
| Backend (now) | in-memory mock store |
| Backend (later) | Firebase Auth + Cloud Firestore (already implemented, behind a flag) |

## Quick start

```bash
# Flutter SDK is at ~/flutter on this machine:
export PATH="$HOME/flutter/bin:$PATH"

flutter pub get
dart run build_runner build      # generate freezed / json code
flutter test                     # run the balance-engine unit tests
flutter run                      # launch on a simulator, device, or chrome
```

Run against Firebase instead of mock (after adding config — see the Firebase doc):

```bash
flutter run --dart-define=USE_FIREBASE=true
```

## Project structure (top level)

```
lib/
├── app/         MaterialApp, router, theme, provider wiring, firebase backend
├── core/        cross-cutting: Money value type, formatting, shared widgets
├── data/mock/   in-memory store + seed data
├── data/firebase/  Firestore mappers + seeder
└── features/    one folder per feature, each with domain / data / application / presentation
test/            unit tests for the money + balance/split/settlement engine
docs/            the guides linked above
```

## Testing

The important logic — splitting an expense and computing balances/settlements —
is pure Dart with no Flutter or I/O dependency, and is covered by unit tests in
`test/`:

```bash
flutter test           # 35 tests: money, split, balance, settlement
flutter analyze        # 0 issues
```
