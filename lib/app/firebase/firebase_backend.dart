import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../../features/auth/data/firebase_auth_repository.dart';
import '../../features/budgets/data/firebase_budget_repository.dart';
import '../../features/expenses/data/firebase_expense_repository.dart';
import '../../features/friends/data/firebase_friend_repository.dart';
import '../../features/groups/data/firebase_group_repository.dart';
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

  return [
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
  ];
}
