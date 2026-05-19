// lib/modules/friends/widgets/friend_card.dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/friend_model.dart';
import '../../../data/models/user_model.dart';

class FriendCard extends StatelessWidget {
  final String name;
  final String username;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const FriendCard({
    super.key,
    required this.name,
    required this.username,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  /// FriendModel'den oluştur. Karşı tarafın adını göstermek için
  /// [currentUid] gereklidir.
  factory FriendCard.fromFriend({
    Key? key,
    required FriendModel friend,
    required String currentUid,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return FriendCard(
      key: key,
      name: friend.getOtherName(currentUid),
      username: friend.getOtherUsername(currentUid),
      trailing: trailing,
      onTap: onTap,
    );
  }

  factory FriendCard.fromUser({
    Key? key,
    required UserModel user,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return FriendCard(
      key: key,
      name: user.name,
      username: user.username,
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.10),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('@$username',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
