import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

/// Root widget: wires themes, the router and system-driven light/dark mode.
class SplitwiseApp extends StatefulWidget {
  const SplitwiseApp({super.key});

  @override
  State<SplitwiseApp> createState() => _SplitwiseAppState();
}

class _SplitwiseAppState extends State<SplitwiseApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Splitwise Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
