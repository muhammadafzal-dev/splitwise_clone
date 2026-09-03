import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'app/app.dart';
import 'app/firebase/firebase_backend.dart';

/// Backend selector. Defaults to the in-memory mock so the app runs with zero
/// configuration. To use Firebase: add the native config files and run with
/// `flutter run --dart-define=USE_FIREBASE=true`.
const _useFirebase = bool.fromEnvironment('USE_FIREBASE');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The ONLY place the backend is chosen. Mock and Firebase implement the same
  // repository interfaces; everything above the data layer is identical.
  final overrides = _useFirebase
      ? await initializeFirebaseBackend()
      : const <Override>[];

  runApp(ProviderScope(overrides: overrides, child: const SplitwiseApp()));
}
