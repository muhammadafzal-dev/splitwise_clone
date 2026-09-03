import 'package:flutter/material.dart';

import '../../features/auth/domain/entities/app_user.dart';

/// Circular avatar showing a user's initials over their brand colour.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 20});

  final AppUser user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = Color(user.avatarColor);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        _initials(user.name),
        style: TextStyle(
          color: _onColor(color),
          fontWeight: FontWeight.w600,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  static Color _onColor(Color background) =>
      background.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
}

/// A small overlapping stack of avatars for group member previews.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.users,
    this.radius = 14,
    this.max = 4,
  });

  final List<AppUser> users;
  final double radius;
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = users.take(max).toList();
    final overflow = users.length - shown.length;
    final overlap = radius * 1.2;
    final width = shown.isEmpty
        ? 0.0
        : radius * 2 +
              (shown.length - 1) * overlap +
              (overflow > 0 ? overlap : 0);

    return SizedBox(
      height: radius * 2,
      width: width,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * overlap,
              child: _ringed(
                context,
                UserAvatar(user: shown[i], radius: radius),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: shown.length * overlap,
              child: _ringed(
                context,
                CircleAvatar(
                  radius: radius,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  child: Text(
                    '+$overflow',
                    style: TextStyle(
                      fontSize: radius * 0.7,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _ringed(BuildContext context, Widget child) => Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Theme.of(context).scaffoldBackgroundColor,
        width: 2,
      ),
    ),
    child: child,
  );
}
