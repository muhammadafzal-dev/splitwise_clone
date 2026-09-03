# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/) and the project follows
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Expense detail sheet showing the full per-person split breakdown.
- Professional repo scaffolding: MIT license, CI (analyze + test + web build),
  contribution guide, issue/PR templates.
- Widget smoke test and mock-repository tests.

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
