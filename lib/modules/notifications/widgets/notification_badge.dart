import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/notification_service.dart';
import '../pages/notifications_page.dart';

class NotificationBadgeButton extends StatelessWidget {
  const NotificationBadgeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final service = Get.find<NotificationService>();
    final uid = auth.currentUser?.uid ?? '';
    return StreamBuilder<int>(
      stream: service.unreadCountStream(uid),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => Get.to(() => const NotificationsPage()),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.debt, borderRadius: BorderRadius.circular(20)),
                  child: Text(count > 9 ? '9+' : '$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              ),
          ],
        );
      },
    );
  }
}
