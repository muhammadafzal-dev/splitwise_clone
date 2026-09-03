<div align="center">

# 💸 Splitwise Clone

**A portfolio-grade, Splitwise-style expense-sharing app in Flutter — built
mock-first with clean architecture, so the backend swaps to Firebase in one file.**

[![CI](https://github.com/muhammadafzal-dev/splitwise_clone/actions/workflows/ci.yml/badge.svg)](https://github.com/muhammadafzal-dev/splitwise_clone/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![style: flutter lints](https://img.shields.io/badge/style-flutter__lints-40c4ff.svg)](https://pub.dev/packages/flutter_lints)

</div>

---

## ✨ Highlights

- 🧮 **Correct money math** — split an expense EQUAL / EXACT / PERCENT and settle
  debts, all in a **pure, unit-tested engine** using integer cents (never floats).
- 🔌 **Backend-swappable** — mock and Firebase implement the same interfaces;
  switching is a single provider override.
- 🎨 **Material 3** — light + dark, responsive, with loading / empty / error
  states everywhere.
- 🧪 **Tested & clean** — `flutter analyze` reports 0 issues; the balance logic is
  covered by adversarial unit tests.

## 📱 Screenshots

> _Add screenshots to `docs/screenshots/` and they'll render here._

| Groups | Group detail | Add expense | Activity |
|:---:|:---:|:---:|:---:|
| ![Groups](docs/screenshots/groups.png) | ![Detail](docs/screenshots/group_detail.png) | ![Add](docs/screenshots/add_expense.png) | ![Activity](docs/screenshots/activity.png) |

Capture them quickly with:

```bash
flutter run            # then use the device/simulator screenshot shortcut
```

## 🚀 Quick start

```bash
export PATH="$HOME/flutter/bin:$PATH"    # or your Flutter install
flutter pub get
dart run build_runner build              # generate freezed / json code
flutter test                             # run the unit + widget tests
flutter run                              # launch (simulator / device / chrome)
```

Run against Firebase instead of the mock backend (see
[docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md)):

```bash
flutter run --dart-define=USE_FIREBASE=true
```

## 🧩 Features

| Area | What it does |
|------|--------------|
| **Auth** | Switch between demo users (mock stand-in for Firebase Auth) |
| **Friends** | Per-user friend list |
| **Groups** | Create groups, add members, per-group emoji + currency |
| **Expenses** | Payer, amount, participants, **category**, split **EQUAL / EXACT / PERCENT** with live validation |
| **Balances** | Net "who owes whom" per group **and** overall (per-currency) |
| **Settle up** | Suggested minimal payments + record a payment |
| **Search & filter** | Filter a group's expenses by text and category |
| **Insights** | Total spent, spend-by-category donut, monthly bars — from a pure, tested analyzer |
| **Budgets** | Monthly limit per category with live progress + over-budget warnings |
| **Salary & savings** | Add salary to start a pay cycle; on next salary, close it (leftover → savings or used) and start a new one; running savings total + history |
| **Currency** | Per-user preferred currency (USD/EUR/PKR/GBP/JPY); per-group currency |
| **Personal expenses** | Log solo (non-split) expenses in a private ledger; counted in Insights |
| **Activity** | Unified feed of expenses and settlements |
| **Profile** | Current user, friends, user switcher |

## 🏗️ Architecture

Feature-first folders, clean layers, dependencies pointing inward:

```
presentation ──▶ application ──▶ domain ◀── data (mock | firebase)
   widgets         providers      pure        implementations
```

The UI and domain only ever depend on repository **interfaces**, so the entire
backend swaps by overriding four providers in `lib/app/providers.dart`.

📚 **Docs (read in this order):**
1. [Concepts](docs/CONCEPTS.md) — the ideas (clean architecture, Riverpod, freezed, integer money, the split math)
2. [Architecture](docs/ARCHITECTURE.md) — how the layers fit + data flow
3. [Build journey](docs/BUILD_JOURNEY.md) — every step to build this, with the *why*
4. [Firebase setup](docs/FIREBASE_SETUP.md) — turn on the Firebase backend

## 🛠️ Tech stack

| Concern | Choice |
|--------|--------|
| State | Riverpod 3 |
| Routing | go_router |
| Models / JSON | freezed + json_serializable |
| Formatting | intl |
| Backend (now) | in-memory mock store |
| Backend (later) | Firebase Auth + Cloud Firestore (implemented, behind a flag) |

## 📂 Project structure

```
lib/
├── app/          MaterialApp, router, theme, provider wiring, firebase backend
├── core/         Money value type, formatting, shared widgets
├── data/
│   ├── mock/     in-memory store + seed data
│   └── firebase/ Firestore mappers + seeder
└── features/     auth · friends · groups · expenses · activity · profile
                  (each: domain / data / application / presentation)
test/             money + balance/split/settlement + repos + widget smoke
docs/             concepts, architecture, build journey, firebase setup
```

## ✅ Quality

```bash
dart format lib test    # formatting
flutter analyze         # 0 issues
flutter test            # unit + widget tests
```

The split/balance/settlement logic is pure Dart (no Flutter, no I/O) and tested
in isolation — the right place for correctness in money code.

## 🗺️ Roadmap

- [ ] Firebase Auth sign-in UI (email / Google)
- [ ] Edit & delete expenses
- [ ] Multi-currency balances (per-currency grouping)
- [ ] Expense categories & search
- [ ] Push notifications on new expenses
- [ ] Golden tests for key screens

## 📄 License

[MIT](LICENSE) © Muhammad Afzal
