# Contributing

Thanks for your interest in improving this project! This guide keeps changes
consistent and easy to review.

## Getting started

```bash
export PATH="$HOME/flutter/bin:$PATH"   # or your Flutter install
flutter pub get
dart run build_runner build             # generate freezed / json
flutter test
flutter run
```

## Architecture in one line

Feature-first + clean layers: UI/domain depend only on repository **interfaces**;
mock and Firebase are interchangeable implementations. Read `docs/ARCHITECTURE.md`
before making structural changes.

## Ground rules

- **Money is integer minor units** (`Money`), never a `double`. Format only at
  the UI edge.
- **Business logic stays pure** in `features/*/domain` and must be unit-tested.
  If you change the split/balance/settlement math, add or update tests in
  `test/`.
- **Immutability** — never mutate entities; use `copyWith`.
- **UI depends on interfaces**, never on a concrete repository or on Firebase.
- Keep files small and focused; extract widgets.

## Before you open a PR

```bash
dart format lib test
flutter analyze        # must be clean (0 issues)
flutter test           # must be green
```

- Follow Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`,
  `chore:`).
- Keep PRs focused and under ~400 lines where possible.
- Update docs when behaviour changes.

## Regenerating code

Any change to a `@freezed` class or JSON model needs codegen:

```bash
dart run build_runner build
```

Generated files (`*.freezed.dart`, `*.g.dart`) are committed so the project
builds without a codegen step.
