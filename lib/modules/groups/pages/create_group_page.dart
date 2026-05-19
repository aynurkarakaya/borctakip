// lib/modules/groups/pages/create_group_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/friend_model.dart';
import '../../../data/services/auth_service.dart';
import '../../friends/widgets/friend_card.dart';
import '../controllers/groups_controller.dart';

class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateGroupController());
    final currentUid =
        Get.find<AuthService>().currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Grup Oluştur',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  hintText: 'Grup adı',
                  prefixIcon:
                      Icon(Icons.groups_rounded, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Üyeleri Seç',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<FriendModel>>(
              stream: controller.friendsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                final friends = snapshot.data ?? [];
                if (friends.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Grup kurmak için önce arkadaş eklemelisin.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }
                return Obx(() => ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: friends.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        final friendId =
                            friend.getOtherUid(currentUid) ?? friend.id;
                        final selected = controller.selectedFriends
                            .any((item) =>
                                (item.getOtherUid(currentUid) ?? item.id) ==
                                friendId);
                        return FriendCard.fromFriend(
                          friend: friend,
                          currentUid: currentUid,
                          onTap: () => controller.toggleFriend(friend),
                          trailing: Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        );
                      },
                    ));
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.createGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Grubu Oluştur',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
