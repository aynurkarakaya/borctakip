// lib/modules/friends/pages/friends_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/friend_model.dart';
import '../../../data/models/friend_request_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/friend_service.dart';
import '../../groups/pages/create_group_page.dart';
import '../../groups/pages/group_details_page.dart';
import '../../notifications/pages/notifications_page.dart';
import '../controllers/friends_controller.dart';
import '../widgets/friend_card.dart';
import 'add_friend_page.dart';
import 'friend_requests_page.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FriendsController());
    final currentUid =
        Get.find<AuthService>().currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Arkadaşlar',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Bildirimler',
            onPressed: () => Get.to(() => const NotificationsPage()),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: 'Arkadaş ekle',
            onPressed: () => Get.to(() => const AddFriendPage()),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => Get.to(() => const CreateGroupPage()),
        icon: const Icon(Icons.group_add_rounded),
        label: const Text('Grup Oluştur',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── İstek bildirim kartı ───────────────────────────────────────
          StreamBuilder<List<FriendRequestModel>>(
            stream: controller.incomingRequestsStream,
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return _ActionTile(
                icon: Icons.mark_email_unread_outlined,
                title: 'Arkadaşlık İstekleri',
                subtitle: count == 0
                    ? 'Bekleyen istek yok'
                    : '$count bekleyen istek var',
                badge: count,
                onTap: () => Get.to(() => const FriendRequestsPage()),
              );
            },
          ),
          const SizedBox(height: 10),

          // ── Arkadaş ekle ──────────────────────────────────────────────
          _ActionTile(
            icon: Icons.person_search_rounded,
            title: 'Arkadaş Ekle',
            subtitle: 'Kullanıcı adıyla ara ve istek gönder',
            onTap: () => Get.to(() => const AddFriendPage()),
          ),
          const SizedBox(height: 24),

          // ── Arkadaşlar başlığı ─────────────────────────────────────────
          const Text('Arkadaşların',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          StreamBuilder<List<FriendModel>>(
            stream: controller.friendsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ));
              }
              final friends = snapshot.data ?? [];
              if (friends.isEmpty) {
                return const _EmptyState(
                  icon: Icons.group_outlined,
                  title: 'Henüz arkadaşın yok',
                  subtitle:
                      'Borç yazabilmek için önce karşı tarafla arkadaş olmalısın.',
                );
              }
              return Column(
                children: friends
                    .map((friend) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: FriendCard(
                            name: friend.getOtherName(currentUid),
                            username: friend.getOtherUsername(currentUid),
                          ),
                        ))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          // ── Gruplar başlığı ────────────────────────────────────────────
          const Text('Grupların',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _GroupsPreview(currentUid: currentUid),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ─── Groups ───────────────────────────────────────────────────────────────────

class _GroupsPreview extends StatelessWidget {
  final String currentUid;
  const _GroupsPreview({required this.currentUid});

  @override
  Widget build(BuildContext context) {
    final service = Get.find<FriendService>();
    return StreamBuilder<List<GroupModel>>(
      stream: service.groupsStream(currentUid),
      builder: (context, snapshot) {
        final groups = snapshot.data ?? [];
        if (groups.isEmpty) {
          return const _EmptyState(
            icon: Icons.groups_2_outlined,
            title: 'Grup yok',
            subtitle:
                'Grup kurarak birden fazla kişiye aynı anda borç isteği gönderebilirsin.',
          );
        }
        return Column(
          children: groups
              .map((group) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      leading: const CircleAvatar(
                          backgroundColor: AppColors.surfaceVariant,
                          child: Icon(Icons.groups_rounded,
                              color: AppColors.primary)),
                      title: Text(group.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle:
                          Text('${group.memberIds.length} üye'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          Get.to(() => GroupDetailsPage(group: group)),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

// ─── Ortak widget'lar ─────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int badge;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: badge > 0
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.debt,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$badge',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            )
          : const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: AppColors.textTertiary),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
