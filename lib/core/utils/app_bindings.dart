import 'package:get/get.dart';

import '../../data/repositories/transaction_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/friend_service.dart';
import '../../data/services/notification_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);
    Get.put(TransactionRepository(), permanent: true);
    Get.put(NotificationService(), permanent: true).init();
    Get.put(FriendService(), permanent: true);
  }
}
