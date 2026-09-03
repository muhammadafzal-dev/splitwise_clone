# Build journey

Every step taken to build this app, in order, with the reasoning behind each.
This is the "how was it made" narrative — follow it top to bottom to understand
how the project came together. Each **Phase** matches a git commit.

---

## Phase 0 — Toolchain

**Goal:** a working Flutter environment.

1. `flutter doctor` — confirm the toolchain. On this machine the SDK wasn't
   installed, so it was cloned to `~/flutter` (stable → **Flutter 3.47.2 / Dart
   3.13.2**). Every shell session needs:
   ```bash
   export PATH="$HOME/flutter/bin:$PATH"
   ```
2. Xcode and Chrome were present; Android cmdline-tools were missing (only blocks
   Android builds — iOS/web/tests are fine).

**Gotcha discovered later:** Dart 3.13 *removed the `final` parameter modifier*,
which broke freezed 3's generated code. The fix was to move to freezed 4 (see
Phase 2). Recorded in `spec/learnings/infrastructure-flutter-toolchain.md`.

---

## Phase 1 — Project + dependencies

**Goal:** create the app and pull in the libraries.

```bash
flutter create --org com.gsoft --project-name splitwise_clone --platforms=ios,android .
flutter pub add flutter_riverpod riverpod_annotation go_router \
  freezed_annotation json_annotation intl uuid
flutter pub add dev:build_runner dev:freezed dev:json_serializable \
  dev:riverpod_generator dev:mocktail
```

Then `analysis_options.yaml` was tightened (strict-casts, prefer_const, trailing
commas, `avoid_dynamic_calls`, etc.) so the analyzer enforces quality.

**Why these libraries:** see `CONCEPTS.md`. In short — Riverpod (state), go_router
(navigation), freezed + json (models that serialise for Firestore later), intl
(formatting), uuid (ids).

---

## Phase 2 — Core building blocks

**Goal:** the primitives every feature reuses. Nothing app-specific yet.

- `core/money/currency.dart` — `Currency` enum (code, symbol, decimal digits).
- `core/money/money.dart` — the **`Money` value type**: an integer count of minor
  units (cents). No doubles anywhere. This is the foundation of correct money math.
- `core/formatting/` — `MoneyFormatter` and `DateFormatter` using `intl`. The only
  place money becomes a display string.
- `core/widgets/` — `LoadingView`, `EmptyView`, `ErrorView`, and `AsyncValueView`
  (maps a Riverpod `AsyncValue` onto those three), plus `UserAvatar`/`AmountText`.
  This is how "loading/empty/error everywhere" is achieved without repetition.

---

## Phase 3 — Domain: entities + repository interfaces

**Goal:** define *what* the app is, independent of *how* it's stored.

- Entities with freezed + json: `AppUser`, `Group`, `Expense`, `Settlement`, and a
  `SplitType` enum. Money-carrying entities store `amountMinorUnits` + a
  `currencyCode` string (plain, Firestore-friendly) and expose a typed `Money`
  getter.
  - `AppUser` is deliberately named so it never clashes with Firebase's `User`.
- Repository **interfaces**: `AuthRepository`, `FriendRepository`,
  `GroupRepository`, `ExpenseRepository`. These are the contracts the rest of the
  app depends on. All methods return `Stream`s (reactive, Firestore-shaped).

**Freezed 4 upgrade happened here:** freezed 3's generated constructors used
`final` on parameters, which Dart 3.13 rejects. Upgrading to freezed 4 fixed it,
but freezed 4 needs `analyzer >=13`, which conflicted with `custom_lint`/
`riverpod_lint` (they cap analyzer at 8). Those two dev-only lint packages were
dropped to unblock. `dart run build_runner build` then generated the
`*.freezed.dart` / `*.g.dart` files cleanly.

---

## Phase 4 — The balance engine (test-first)

**Goal:** the core value of the app — correct splitting and settlement — built as
pure, tested Dart. **Tests were written before/with the implementation.**

`features/expenses/domain/balance/`:
- `split_calculator.dart` — expense → per-person cents (EQUAL / EXACT / PERCENT),
  always summing exactly to the total; throws `SplitException` on bad input.
- `balance_calculator.dart` — expenses + settlements → net per person; asserts the
  totals conserve to zero.
- `settlement_calculator.dart` — net balances → minimal "who pays whom".
- `balance.dart` — `Balance` and `DebtEdge` value types.

`test/` covers adversarial cases: rounding remainders, awkward amounts, single
participant, over/under-specified EXACT and PERCENT, tie-breaking, conservation to
zero, greedy settlement correctness. **35 tests, all green.**

Why test-first here specifically: money correctness is non-negotiable, and pure
functions are the easiest thing in the codebase to test exhaustively.

---

## Phase 5 — Mock data layer

**Goal:** a working backend with zero external dependencies.

- `data/mock/mock_store.dart` — one reactive in-memory store. Replays the current
  snapshot to new listeners (after a small simulated latency so loading states
  show), then emits a new snapshot on every mutation — mimicking Firestore.
- `data/mock/seed_data.dart` — 4 users, 2 groups, 6 expenses (all three split
  types), 1 settlement, full friend graph.
- `features/*/data/mock_*_repository.dart` — the four interfaces implemented
  against the store.
- `app/providers.dart` — **the swap point**: exposes each repository as its
  interface. Plus `application/` providers per feature (raw streams + derived
  balances/feed).

---

## Phase 6 — App shell

**Goal:** themes, navigation, and the composition root.

- `app/theme.dart` — Material 3 light + dark from one seed color; semantic
  balance colors (green owed / red owing).
- `app/router.dart` + `home_shell.dart` — go_router with a `StatefulShellRoute`
  for the three tabs and pushed detail routes.
- `app/app.dart` + `main.dart` — `MaterialApp.router` inside a single
  `ProviderScope`.

---

## Phase 7 — Presentation (all screens)

**Goal:** the UI, every screen with loading/empty/error states.

- Groups list + overall summary card, group tile with per-user balance.
- Group detail: "who owes whom" + expense list + settle-up entry.
- Add expense: description, amount, payer, participants, split selector with
  per-split editors and **live "remaining" validation**; validates via
  `SplitCalculator` before saving.
- Settle up: suggested payments + record a payment.
- Create group, activity feed, profile, user-switcher sheet.

Small, focused widgets throughout; shared building blocks come from `core/widgets`.

---

## Phase 8 — Verification

**Goal:** prove it works.

```bash
flutter analyze     # No issues found
flutter test        # 35 passed
flutter build web   # compiles end to end
```

**Riverpod 3 note:** `AsyncValue.valueOrNull` was removed — replaced with
`AsyncValue.value` (nullable) throughout.

---

## Phase 9 — Firebase backend (implemented, behind a flag)

**Goal:** make the mock → Firebase swap real, without disturbing mock mode.

```bash
flutter pub add firebase_core firebase_auth cloud_firestore
```

- `data/firebase/firestore_mappers.dart` — entity ↔ Firestore doc mapping
  (`Timestamp`, denormalised `involvedIds`).
- `features/*/data/firebase_*_repository.dart` — the four interfaces implemented
  against Firestore/Auth (auth-state × user-doc switching, array-contains queries,
  batched friend writes).
- `app/firebase/firebase_backend.dart` — `Firebase.initializeApp()` (native config
  files supply options; no `firebase_options.dart` needed) + the four provider
  overrides.
- `main.dart` — chooses backend from `--dart-define=USE_FIREBASE=true`; defaults to
  mock so the app still runs with no config.
- `firestore.rules`, `firestore.indexes.json`, `data/firebase/firebase_seeder.dart`,
  and `FIREBASE_SETUP.md`.

**Riverpod 3 note:** the `Override` type isn't in the default barrel export — it's
imported from `package:flutter_riverpod/misc.dart`.

Result: `flutter analyze` clean, 35 tests green, web build succeeds — with both
backends compiled in.

---

## Phase 10 — Documentation

The `docs/` you're reading now: `CONCEPTS.md`, `ARCHITECTURE.md`, this journey,
and `FIREBASE_SETUP.md`; plus `spec/learnings/` capturing the toolchain gotchas.
