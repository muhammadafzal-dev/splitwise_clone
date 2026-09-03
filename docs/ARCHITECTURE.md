# Architecture

Read `CONCEPTS.md` first for the ideas. This document shows how the pieces fit
and how data flows end to end.

---

## Folder map

```
lib/
├── app/                         # Composition root — wires everything together
│   ├── app.dart                 #   MaterialApp.router + themes
│   ├── router.dart              #   go_router: shell + routes
│   ├── home_shell.dart          #   bottom navigation scaffold
│   ├── theme.dart               #   Material 3 light/dark + balance colors
│   ├── providers.dart           #   ← THE SWAP POINT (repo providers)
│   └── firebase/
│       └── firebase_backend.dart#   Firebase init + provider overrides
│
├── core/                        # Cross-cutting, feature-agnostic
│   ├── money/                   #   Money (integer cents) + Currency
│   ├── formatting/              #   intl money & date formatters
│   └── widgets/                 #   LoadingView / EmptyView / ErrorView,
│                                #   AsyncValueView, UserAvatar, AmountText
│
├── data/
│   ├── mock/                    #   MockStore (reactive in-memory) + seed data
│   └── firebase/                #   Firestore mappers + optional seeder
│
└── features/<feature>/
    ├── domain/                  #   entities (freezed) + repository INTERFACE
    ├── data/                    #   mock + firebase implementations
    ├── application/             #   Riverpod providers (raw + derived)
    └── presentation/            #   screens + widgets
```

Features: `auth`, `friends`, `groups`, `expenses` (contains the balance engine),
`activity`, `profile`.

---

## The dependency rule

```
presentation ──▶ application ──▶ domain ◀── data
                                   ▲
                                 core (money, etc.)
```

- Arrows point toward `domain`. Nothing in `domain` imports Flutter, Firebase, or
  a concrete repository.
- `data` implementations depend on `domain` (they implement its interfaces).
- `presentation` never imports `data` directly — it only sees interfaces through
  providers.

This is what makes the backend swappable.

---

## The four repository interfaces

Defined in `features/*/domain/`:

| Interface | Responsibility |
|-----------|----------------|
| `AuthRepository` | current user, user directory, sign in/out |
| `FriendRepository` | a user's friends, add friend |
| `GroupRepository` | groups for a user, create group, add member |
| `ExpenseRepository` | expenses & settlements (per-group and per-user), add |

Each has **two implementations**:
`Mock*Repository` (in `features/*/data/`, reads `MockStore`) and
`Firebase*Repository` (reads Firestore).

---

## The swap point

`lib/app/providers.dart` exposes each repository as its interface:

```dart
final groupRepositoryProvider = Provider<GroupRepository>(
  (ref) => MockGroupRepository(ref.watch(mockStoreProvider)),
);
```

To use Firebase, `main.dart` supplies overrides built in
`app/firebase/firebase_backend.dart`:

```dart
groupRepositoryProvider.overrideWithValue(FirebaseGroupRepository(firestore))
```

`main.dart` picks the backend from a compile-time flag:

```dart
const _useFirebase = bool.fromEnvironment('USE_FIREBASE');
final overrides = _useFirebase ? await initializeFirebaseBackend() : const [];
runApp(ProviderScope(overrides: overrides, child: const SplitwiseApp()));
```

**That is the entire difference between mock and Firebase.** No screen, provider,
or entity changes.

---

## Data flow: rendering a group's balances

```
GroupDetailScreen
  └─ watches groupBalancesProvider(groupId)          [application]
       └─ combines groupExpensesProvider(groupId)
                 + groupSettlementsProvider(groupId)  [application, StreamProviders]
            └─ ExpenseRepository.watchGroupExpenses    [domain interface]
                 └─ Mock or Firebase implementation    [data]
                      └─ MockStore stream / Firestore snapshots
       └─ BalanceCalculator.balances(expenses, settlements)  [domain, pure]
  └─ AsyncValueView renders loading / data / error
```

The screen never knows which backend produced the streams. The math is a pure
function applied to whatever the streams deliver.

---

## Data flow: adding an expense

```
AddExpenseScreen (form)
  → builds an Expense entity (EQUAL/EXACT/PERCENT)
  → SplitCalculator.computeShares(expense)   // validate up front; may throw SplitException
  → ExpenseRepository.addExpense(expense)     // interface
       → Mock: append to MockStore, emit new snapshot
       → Firebase: write a document (with denormalised involvedIds)
  → every StreamProvider watching that data re-emits → balances/feed update live
```

Validation happens *before* persistence, so an inconsistent split is never saved.

---

## Mock backend

`data/mock/mock_store.dart` is a single in-memory source of truth. It holds lists
of users/groups/expenses/settlements and a `friendships` map, and exposes one
reactive `watch()` stream that:

1. replays the current snapshot to each new listener (after a small simulated
   latency, so loading states are visible), then
2. pushes a fresh immutable snapshot on every mutation.

This deliberately mirrors a Firestore snapshot listener, so the mock repositories
read almost identically to the Firebase ones.

`data/mock/seed_data.dart` provides 4 users, 2 groups and 6 expenses across all
three split types plus 1 settlement, so balances are non-trivial out of the box.

---

## Firebase backend

`data/firebase/firestore_mappers.dart` converts entities ↔ Firestore documents,
handling `Timestamp`, and adding a denormalised `involvedIds` array (payer ∪
participants) so a user's overall balance is a single `array-contains` query.

Collections: `users`, `groups`, `expenses`, `settlements` (flat, each expense/
settlement carries `groupId`). Security rules (`firestore.rules`) restrict access
to group members; required composite indexes are in `firestore.indexes.json`. Full
setup in `FIREBASE_SETUP.md`.

---

## Testing strategy

The money and balance/split/settlement logic is pure and lives in `domain`, so it
is tested without a widget tree or a backend (`test/`). Adversarial cases (rounding
remainders, over/under-specified splits, single participant, conservation to zero,
greedy settlement correctness) are covered. This is intentional: for money code,
the tests belong on the math, and the math is isolated precisely so it can be
tested in isolation.
