# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/) and the project follows
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **Offline-first (Firebase backend):** Firestore offline persistence enabled and
  all writes made optimistic (non-blocking), so adding data never hangs without
  internet; queued changes sync automatically on reconnect. Added a connectivity
  provider and an offline/syncing status banner (`connectivity_plus`).
- **Salary & savings:** add a salary to start a pay cycle; when the next salary
  arrives the current cycle is closed (leftover moved to savings or marked used)
  and a new cycle starts. Running savings total + cycle history. New
  `SalaryRepository` (mock + Firebase) and a date-range method on the tested
  `SpendingAnalyzer`.
- **Currency manager:** added PKR; per-user preferred currency (default for new
  groups/budgets/personal/salary) and a per-group currency picker.
- **Expense tracking layer:**
  - Expense **categories** (10 categories with icons/colours) + category picker.
  - **Search & filter** a group's expenses by text and category.
  - **Insights** tab: total spent, spend-by-category donut, monthly bars —
    powered by a pure, unit-tested `SpendingAnalyzer`.
  - **Monthly budgets** per category with live progress and over-budget warnings
    (new `BudgetRepository`, mock + Firebase).
  - **Personal (solo) expenses** via a private per-user ledger.
- Expense detail sheet showing the full per-person split breakdown.
- Professional repo scaffolding: MIT license, CI (analyze + test + web build),
  contribution guide, issue/PR templates.
- Widget smoke test, mock-repository tests, and `SpendingAnalyzer` tests.

### Changed
- Refresh keeps existing content visible instead of flashing a loading spinner.
- Removed unused dependencies (`riverpod_annotation`, `riverpod_generator`,
  `mocktail`).

## [0.1.0] — 2026-09-03

### Added
- Mock-first Splitwise-style app: user switching, friends, groups, expenses with
  EQUAL / EXACT / PERCENT splits, balances, settle-up, activity feed, profile.
- Pure, unit-tested balance engine (split, net balances, minimal settlement).
- Material 3 UI, light + dark, loading/empty/error states.
- Fully implemented Firebase (Auth + Firestore) backend behind a `USE_FIREBASE`
  flag, with security rules, indexes, and a data seeder.
- Documentation: concepts, architecture, build journey, Firebase setup.
