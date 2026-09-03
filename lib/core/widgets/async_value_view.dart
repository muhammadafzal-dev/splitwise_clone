import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state_views.dart';

/// Maps a Riverpod [AsyncValue] onto the app's standard loading/error/data
/// widgets so every screen handles the three states the same way.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.loadingMessage,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final String? loadingMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnRefresh: false,
      data: data,
      loading: () => LoadingView(message: loadingMessage),
      error: (error, _) =>
          ErrorView(message: error.toString(), onRetry: onRetry),
    );
  }
}
