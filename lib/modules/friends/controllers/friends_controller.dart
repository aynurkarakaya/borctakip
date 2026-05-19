// lib/modules/friends/controllers/friends_controller.dart
import 'package:get/get.dart';

import '../../../data/models/friend_model.dart';
import '../../../data/models/friend_request_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/friend_service.dart';

class FriendsController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  final FriendService _friendService = Get.find<FriendService>();

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<List<FriendModel>> get friendsStream =>
      _friendService.friendsStream(uid);

  Stream<List<FriendRequestModel>> get incomingRequestsStream =>
      _friendService.incomingRequestsStream(uid);

  Stream<List<FriendRequestModel>> get outgoingRequestsStream =>
      _friendService.outgoingRequestsStream(uid);

  Future<void> accept(FriendRequestModel request) async {
    try {
      await _friendService.acceptFriendRequest(request);
      Get.snackbar('Kabul Edildi ✓', '${request.fromName} ile artık arkadaşsınız!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Hata', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> reject(String requestId) async {
    try {
      await _friendService.rejectFriendRequest(requestId);
      Get.snackbar('Reddedildi', 'Arkadaşlık isteği reddedildi.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Hata', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Alias methods (bazı sayfalarda doğrudan çağrılıyor)
  Future<void> acceptFriendRequest(FriendRequestModel request) => accept(request);
  Future<void> rejectFriendRequest(String requestId) => reject(requestId);
}
