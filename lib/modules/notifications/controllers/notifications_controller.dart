import 'package:get/get.dart';

import '../../../data/models/app_notification_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/notification_service.dart';

class NotificationsController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  final NotificationService _notificationService = Get.find<NotificationService>();
  final TransactionRepository _transactions = Get.find<TransactionRepository>();

  String get uid => _auth.currentUser?.uid ?? '';
  Stream<List<AppNotificationModel>> get notificationsStream => _notificationService.notificationsStream(uid);
  Stream<int> get unreadCountStream => _notificationService.unreadCountStream(uid);
  Stream<List<TransactionModel>> get incomingDebtRequestsStream => _transactions.incomingDebtRequestsStream(uid);

  Future<void> markAsRead(String id) => _notificationService.markAsRead(id);
  Future<void> markAllAsRead() => _notificationService.markAllAsRead(uid);

  Future<void> approveDebt(TransactionModel tx) async {
    try {
      await _transactions.approveTransaction(tx.id);
      Get.snackbar('Onaylandı', 'Borç isteği aktif borçlara eklendi.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Hata', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> rejectDebt(TransactionModel tx) async {
    try {
      await _transactions.cancelTransaction(tx.id);
      Get.snackbar('Reddedildi', 'Borç isteği reddedildi.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Hata', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
