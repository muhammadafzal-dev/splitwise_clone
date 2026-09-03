# Learning: Flutter toolchain + codegen constraints

**Category:** infrastructure
**Last Updated:** 2026-09-03

## Related Files
- `pubspec.yaml`
- `analysis_options.yaml`
- all `*.freezed.dart` / `*.g.dart`

## Findings

### Flutter SDK location (2026-09-03)
- SDK not installed system-wide. Cloned to `~/flutter` (stable branch → **Flutter 3.47.2 / Dart 3.13.2**).
- Every shell command needs `export PATH="$HOME/flutter/bin:$PATH"` first.
- Android cmdline-tools missing (iOS/web/tests unaffected). Run `flutter doctor --android-licenses` + install cmdline-tools before Android builds.

### Dart 3.13 removed the `final` parameter modifier (2026-09-03)
- Dart 3.13.2 rejects `final` on ANY formal parameter: `Error: Can't have modifier 'final' here.`
- **freezed 3.2.3 generates exactly this** in `_$Model` constructors → generated code won't compile.
- Fix: **freezed 4.0.1** (its generated code is compatible).
- freezed 4 needs `analyzer >=13`, which conflicts with `custom_lint`/`riverpod_lint` (they cap `analyzer ^8`). Resolution: **dropped `custom_lint` + `riverpod_lint`** (dev-only) to unblock. Removed the `custom_lint` plugin line from `analysis_options.yaml`.

### Riverpod 3 API change (2026-09-03)
- `AsyncValue.valueOrNull` is **gone** in riverpod 3.1. Use `AsyncValue.value` (returns `T?`).
- `when` / `maybeWhen` / `requireValue` / `hasValue` / `hasError` / `skipLoadingOnRefresh` still exist.

## Commands
```bash
export PATH="$HOME/flutter/bin:$PATH"
dart run build_runner build      # regenerate freezed/json (no --delete-conflicting-outputs; ignored)
flutter analyze                  # 0 issues
flutter test                     # balance engine specs
flutter build web --no-tree-shake-icons
```

## Change Log
| Date | Change |
|------|--------|
| 2026-09-03 | Initial: SDK path, Dart 3.13 `final`-param removal, freezed 4 upgrade, riverpod 3 `.value` |
