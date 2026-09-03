# Concepts

This document explains the *ideas* behind the app so the code reads clearly.
Read this first, then `ARCHITECTURE.md`.

---

## 1. Clean architecture, feature-first

Two organising principles combine:

**Feature-first** — the top-level folders are *features* (`auth`, `groups`,
`expenses`, `friends`, `activity`, `profile`), not technical types. Everything
about "expenses" lives under `features/expenses/`. This keeps related code
together and makes a feature easy to find, change, or delete.

**Clean layers** — inside each feature there are up to four layers, and
dependencies only ever point *inward*:

```
presentation  →  application  →  domain  ←  data
  (widgets)      (providers)     (pure)    (impls)
```

- **domain** — the heart. Pure Dart: entities (data shapes) and repository
  *interfaces* (contracts). Knows nothing about Flutter, Firebase, or JSON.
- **data** — *implements* the domain interfaces. The mock reads an in-memory
  store; the Firebase version reads Firestore. Both depend on domain, not the
  other way around.
- **application** — Riverpod providers that expose domain data to the UI and
  hold derived state (e.g. computed balances).
- **presentation** — widgets/screens. They depend on application + domain, never
  on data directly.

**Why it matters:** because the UI and business logic only depend on *interfaces*,
you can replace the entire backend (mock → Firebase) without touching them. This
is the single most important property of the codebase.

---

## 2. Repository pattern

A *repository* is an interface that hides where data comes from. Example:

```dart
abstract interface class GroupRepository {
  Stream<List<Group>> watchGroups(String userId);
  Future<Group> createGroup({ ... });
}
```

The rest of the app depends on `GroupRepository`, not on "Firestore" or "a list
in memory". We provide two implementations:

- `MockGroupRepository` — reads an in-memory store.
- `FirebaseGroupRepository` — reads Firestore.

They are interchangeable because they satisfy the same contract. Swapping them is
a one-line provider override (see ARCHITECTURE §"The swap point").

---

## 3. Riverpod (state management)

Riverpod exposes values through **providers**. A widget *watches* a provider and
rebuilds when it changes.

- `Provider<T>` — a plain value (e.g. a repository instance).
- `StreamProvider<T>` — wraps a `Stream`; the UI receives an `AsyncValue<T>` that
  is one of *loading / data / error*. This is why every screen naturally has all
  three states.
- `.family` — a provider parameterised by an argument, e.g.
  `groupExpensesProvider(groupId)`.

`AsyncValue` is the key type: `value.when(loading:…, data:…, error:…)` forces you
to handle every state. The app funnels this through one widget, `AsyncValueView`,
so the pattern is written once.

**Overrides** let you replace what a provider returns. `main.dart` uses this to
inject either the mock or Firebase repositories at startup.

---

## 4. freezed + json_serializable (models)

Writing immutable data classes by hand (constructor, `==`, `hashCode`, `copyWith`,
`toJson`) is tedious and error-prone. `freezed` generates all of it from a small
declaration:

```dart
@freezed
abstract class Group with _$Group {
  const factory Group({ required String id, required String name, ... }) = _Group;
  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}
```

Running `dart run build_runner build` generates `group.freezed.dart` (equality,
copyWith) and `group.g.dart` (JSON). The `fromJson`/`toJson` pair is what makes
Firestore mapping easy later.

**Immutability** (never mutate, always copy with `copyWith`) prevents a whole
class of bugs where shared state changes unexpectedly.

---

## 5. Money as integer minor units (no doubles!)

**Money is never a `double`.** Floating point can't represent `0.10` exactly, so
`0.10 * 3` drifts and cents get lost. Instead, `Money` stores an **integer count
of minor units** (cents):

```dart
Money(1234, Currency.usd)   // = $12.34
```

All arithmetic (adding expenses, splitting, settling) happens in integers, so
totals always reconcile to the exact cent. Conversion to a human string happens
only at the UI edge via `intl`. This is how real financial software handles money.

---

## 6. The split & balance math

Three pure functions, each independently unit-tested (`test/balance/`):

### SplitCalculator — one expense → each person's share (cents)
- **EQUAL:** divide, then hand out the leftover cents one at a time so shares sum
  *exactly* to the total. `$10.00 / 3 → 3.34, 3.33, 3.33`.
- **EXACT:** caller supplies each person's cents; validated to sum to the total.
- **PERCENT:** basis points (10000 = 100%); *largest-remainder rounding* keeps the
  cents exact.

### BalanceCalculator — many expenses + settlements → net per person
For each expense: the payer is credited the full amount; each participant is
debited their share. A settlement moves money between two people. The result is a
map `userId → net`, where **positive means "is owed"** and **negative means
"owes"**. An invariant (asserted in code) guarantees all balances **sum to zero** —
money is conserved.

### SettlementCalculator — net balances → minimal "who pays whom"
A greedy algorithm repeatedly matches the biggest debtor to the biggest creditor,
reducing an N-way tangle of debts to a short list of payments. Guarantee: applying
the suggested payments leaves everyone at zero.

Keeping this logic pure (no Flutter, no I/O) is what makes it trivially testable —
and tests are where correctness for money code has to live.

---

## 7. go_router (navigation)

Declarative, URL-based routing. A `StatefulShellRoute` gives the three
bottom-navigation tabs (Groups / Activity / Profile) each their own navigation
stack that survives tab switches. Detail screens (group, add-expense, settle-up)
are pushed on top. Routes are defined once in `app/router.dart`, and screens
navigate with helpers like `AppRoutes.groupDetail(id)` — no magic strings.

---

## 8. Streams everywhere (reactivity)

Both backends expose data as **streams**, because Firestore is push-based: when a
document changes, listeners get a new snapshot automatically. The mock store
mimics this (it emits a fresh snapshot on every change). Because the app consumes
streams via `StreamProvider`, the UI updates live when data changes — and the mock
behaves like Firestore will, so nothing surprises you at swap time.
