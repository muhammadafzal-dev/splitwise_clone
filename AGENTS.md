# Project instructions

## Git workflow

- Do **not** automatically create commits or push changes.
- After making and verifying a change, report the working-tree status and wait
  for the user to explicitly request `commit` or `commit and push`.
- Do not amend, squash, or otherwise alter existing commits unless explicitly
  requested.

## iOS workflow

- iOS is deferred until the user explicitly requests it.
- Do **not** run `pod install`, `flutter run -d ios`, `flutter build ios`, or
  any command that resolves or modifies CocoaPods dependencies.
- Do not add `GoogleService-Info.plist` or otherwise configure Firebase for iOS
  until requested. Android Firebase configuration may proceed independently.
