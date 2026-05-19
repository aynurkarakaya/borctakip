import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../models/app_notification_model.dart';
import 'auth_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final AuthService _auth = Get.find<AuthService>();

  CollectionReference get _notifications => _db.collection('notifications');

  Future<NotificationService> init() async {
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      await saveCurrentToken();
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification != null) {
          Get.snackbar(notification.title ?? 'Bildirim', notification.body ?? '');
        }
      });
    } catch (_) {
      // Firebase Messaging bazı masaüstü ortamlarda desteklenmeyebilir.
      // Uygulama içi Firestore bildirimleri yine çalışmaya devam eder.
    }
    return this;
  }

  Future<void> saveCurrentToken() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      final token = await _messaging.getToken();
      if (token == null) return;
      await _db.collection('users').doc(uid).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastFcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Stream<List<AppNotificationModel>> notificationsStream(String uid) {
    return _notifications
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AppNotificationModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<int> unreadCountStream(String uid) {
    return _notifications
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required AppNotificationType type,
    Map<String, dynamic> data = const {},
  }) async {
    final notification = AppNotificationModel(
      id: '',
      userId: userId,
      title: title,
      body: body,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
      data: data,
    );
    await _notifications.add(notification.toMap());
  }

  Future<void> markAsRead(String notificationId) async {
    await _notifications.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String uid) async {
    final snap = await _notifications
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
