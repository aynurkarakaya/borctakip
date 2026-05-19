// lib/modules/groups/controllers/groups_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/friend_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/friend_service.dart';

class CreateGroupController extends GetxController {
  final FriendService _friendService = Get.find<FriendService>();
  final AuthService _auth = Get.find<AuthService>();
  final nameController = TextEditingController();
  final selectedFriends = <FriendModel>[].obs;
  final isSaving = false.obs;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<List<FriendModel>> get friendsStream =>
      _friendService.friendsStream(uid);

  void toggleFriend(FriendModel friend) {
    final friendId = friend.getOtherUid(uid) ?? friend.id;
    final existingIndex = selectedFriends.indexWhere(
        (item) => (item.getOtherUid(uid) ?? item.id) == friendId);
    if (existingIndex >= 0) {
      selectedFriends.removeAt(existingIndex);
    } else {
      selectedFriends.add(friend);
    }
  }

  Future<void> createGroup() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Eksik Bilgi', 'Grup adı yazmalısın.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedFriends.isEmpty) {
      Get.snackbar('Eksik Bilgi', 'En az bir arkadaş seçmelisin.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isSaving.value = true;
    try {
      await _friendService.createGroup(name, selectedFriends.toList());
      Get.back();
      Get.snackbar('Grup Oluşturuldu ✓', '"$name" grubu hazır.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
    } catch (e) {
      Get.snackbar('Hata', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}

class GroupDetailsController extends GetxController {
  final FriendService _friendService = Get.find<FriendService>();
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final isSaving = false.obs;

  Future<void> sendGroupDebt(GroupModel group) async {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true;
    try {
      await _friendService.createGroupDebtRequests(
        group: group,
        amount: double.parse(amountController.text.replaceAll(',', '.')),
        description: descriptionController.text.trim(),
      );
      amountController.clear();
      descriptionController.clear();
      Get.snackbar(
        'Gönderildi ✓',
        'Borç isteği grup üyelerine gönderildi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar('Hata', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
