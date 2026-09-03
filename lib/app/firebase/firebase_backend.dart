import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../../features/auth/data/firebase_auth_repository.dart';
import '../../features/budgets/data/firebase_budget_repository.dart';
import '../../features/expenses/data/firebase_expense_repository.dart';
import '../../features/friends/data/firebase_friend_repository.dart';
import '../../features/groups/data/firebase_group_repository.dart';
import '../../features/salary/data/firebase_salary_repository.dart';
import '../providers.dart';

/// Initialises Firebase and returns the provider overrides that replace the
/// in-memory mock repositories with the Firestore-backed ones.
///
/// [Firebase.initializeApp] is called with **no options** — on iOS/Android the
/// native config files (`GoogleService-Info.plist` / `google-services.json`)
/// supply them, so no generated `firebase_options.dart` is required. Add those
/// files, then run with `--dart-define=USE_FIREBASE=true`.
Future<List<Override>> initializeFirebaseBackend() async {
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  // Offline-first: cache all data locally and queue writes made while offline.
  // Firestore replays them and syncs automatically when connectivity returns.
  // (On Android/iOS this is on by default; setting it explicitly also enables
  // web IndexedDB persistence and an unbounded cache.)
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  return [
    // Signals to the UI that a cloud backend (with real sync) is active.
    cloudBackendEnabledProvider.overrideWithValue(true),
    authRepositoryProvider.overrideWithValue(
      FirebaseAuthRepository(auth, firestore),
    ),
    friendRepositoryProvider.overrideWithValue(
      FirebaseFriendRepository(firestore),
    ),
    groupRepositoryProvider.overrideWithValue(
      FirebaseGroupRepository(firestore),
    ),
    expenseRepositoryProvider.overrideWithValue(
      FirebaseExpenseRepository(firestore),
    ),
    budgetRepositoryProvider.overrideWithValue(
      FirebaseBudgetRepository(firestore),
    ),
    salaryRepositoryProvider.overrideWithValue(
      FirebaseSalaryRepository(firestore),
    ),
  ];
}
