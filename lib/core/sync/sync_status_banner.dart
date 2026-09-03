import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import 'connectivity_providers.dart';

/// A thin status strip shown under the app bar area when a cloud backend is
/// active: amber while offline, then a brief green "syncing" when connectivity
/// returns. Renders nothing on the mock backend (everything is already local).
class SyncStatusBanner extends ConsumerStatefulWidget {
  const SyncStatusBanner({super.key});

  @override
  ConsumerState<SyncStatusBanner> createState() => _SyncStatusBannerState();
}

class _SyncStatusBannerState extends ConsumerState<SyncStatusBanner> {
  bool _showSyncing = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cloud = ref.watch(cloudBackendEnabledProvider);
    final online = ref.watch(isOnlineProvider);

    // When we transition offline -> online, flash a "syncing" strip briefly.
    ref.listen<bool>(isOnlineProvider, (prev, next) {
      if (prev == false && next == true) {
        setState(() => _showSyncing = true);
        _timer?.cancel();
        _timer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showSyncing = false);
        });
      }
    });

    if (!cloud) return const SizedBox.shrink();

    if (!online) {
      return const _Strip(
        color: Color(0xFFB45309),
        icon: Icons.cloud_off,
        text: 'Offline — changes are saved and will sync automatically',
      );
    }
    if (_showSyncing) {
      return const _Strip(
        color: Color(0xFF15803D),
        icon: Icons.cloud_sync,
        text: 'Back online — syncing your changes…',
      );
    }
    return const SizedBox.shrink();
  }
}

class _Strip extends StatelessWidget {
  const _Strip({required this.color, required this.icon, required this.text});

  final Color color;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
