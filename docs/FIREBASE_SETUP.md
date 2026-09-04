# Firebase setup

The Firebase backend is **fully implemented** and lives behind a flag. The app
runs on in-memory mock data by default. To switch to Firebase you only add
config + flip the flag — no code changes.

## What's already done (in code)

- `FirebaseAuthRepository`, `FirebaseFriendRepository`, `FirebaseGroupRepository`,
  `FirebaseExpenseRepository` — implement the same domain interfaces as the mocks.
- `lib/app/firebase/firebase_backend.dart` — initialises Firebase and returns the
  provider overrides.
- `lib/main.dart` — chooses backend from `--dart-define=USE_FIREBASE=true`.
- `lib/data/firebase/firestore_mappers.dart` — entity ↔ Firestore document mapping
  (`Timestamp`, denormalised `involvedIds`).
- `firestore.rules` — membership-based security rules.
- `firestore.indexes.json` — the composite indexes the queries need.
- `lib/data/firebase/firebase_seeder.dart` — optional one-shot demo-data seeder.

## Steps for you

1. **Create a Firebase project** at console.firebase.google.com.

2. **Register the apps and add config files** (no `flutterfire configure` needed —
   `Firebase.initializeApp()` reads the native files):
   - Android: put `google-services.json` in `android/app/`.
   - iOS: put `GoogleService-Info.plist` in `ios/Runner/` (add it in Xcode so it's
     bundled).
   - The required Google Services Gradle plugin is already configured in
     `android/settings.gradle.kts` and `android/app/build.gradle.kts`. Do not
     add a second declaration.

3. **Enable Authentication** — turn on a sign-in method (Email/Password or Google)
   in the Firebase console. Note: `signInAs()` (the mock user switcher) is
   intentionally unsupported on Firebase; wire your chosen Firebase sign-in UI and
   ensure a `users/{uid}` doc exists with `name`, `email`, `avatarColor`.

4. **Deploy rules + indexes** (Firebase CLI):
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```
   Or paste `firestore.rules` in the console and let the first query's error link
   auto-create each index.

5. **(Optional) Seed demo data** — call once from a debug action:
   ```dart
   await FirebaseSeeder(FirebaseFirestore.instance).seed();
   ```
   For the signed-in user to match the demo, use their real Auth uid as a
   `users/{uid}` id (or just treat the seed as sample content).

6. **Run against Firebase:**
   ```bash
   flutter run --dart-define=USE_FIREBASE=true
   ```
   Without the flag the app stays on mock data.

## Offline-first & sync

The Firebase backend works fully offline and syncs automatically:

- **Persistence** is enabled in `firebase_backend.dart`
  (`Settings(persistenceEnabled: true, cacheSizeBytes: unlimited)`), so all data
  and any writes made while offline are cached on the device.
- **Writes are optimistic** — the Firebase repositories do *not* await the server
  acknowledgement (which never resolves while offline). The write is applied to
  the local cache immediately, the UI updates from the cache, and Firestore
  replays the queued writes when connectivity returns.
- A **status banner** (top of the app) shows "Offline — changes are saved and
  will sync automatically" while offline, then "Back online — syncing…" on
  reconnect. It only appears on the Firebase backend (the mock is already local).

So the user can keep adding expenses, salaries, budgets, etc. with no internet;
nothing blocks, and everything syncs to the live database once online.

## Data model

```
users/{uid}            name, email, avatarColor, friendIds[]
groups/{groupId}       name, emoji, memberIds[], currencyCode, createdAt
expenses/{expenseId}   groupId, description, payerId, amountMinorUnits,
                       currencyCode, splitType, participantIds[],
                       exactShares{}, percentShares{}, createdAt, involvedIds[]
settlements/{id}       groupId, fromUserId, toUserId, amountMinorUnits,
                       currencyCode, createdAt, involvedIds[]
```

`involvedIds` = payer ∪ participants (expenses) or [from, to] (settlements),
denormalised so per-user queries are a single `array-contains`.
