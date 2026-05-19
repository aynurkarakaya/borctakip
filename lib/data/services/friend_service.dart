// lib/data/services/friend_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/app_notification_model.dart';
import '../models/friend_model.dart';
import '../models/friend_request_model.dart';
import '../models/group_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../repositories/transaction_repository.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class FriendService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth = Get.find<AuthService>();
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final NotificationService _notifications = Get.find<NotificationService>();
  final TransactionRepository _transactions = Get.find<TransactionRepository>();

  // ─── Collections ────────────────────────────────────────────────────────────
  CollectionReference get _friendRequests => _db.collection('friend_requests');
  CollectionReference get _friends => _db.collection('friends');
  CollectionReference get _groups => _db.collection('groups');

  String? get currentUid => _auth.currentUser?.uid;

  String _friendshipId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  STREAMS
  // ════════════════════════════════════════════════════════════════════════════

  /// Kullanıcının arkadaşlarını gerçek zamanlı dinler.
  Stream<List<FriendModel>> friendsStream(String uid) {
    return _friends
        .where('users', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                FriendModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Gelen bekleyen istekler
  Stream<List<FriendRequestModel>> incomingRequestsStream(String uid) {
    return _friendRequests
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapRequests);
  }

  /// Gönderilen bekleyen istekler
  Stream<List<FriendRequestModel>> outgoingRequestsStream(String uid) {
    return _friendRequests
        .where('fromUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapRequests);
  }

  Stream<List<GroupModel>> groupsStream(String uid) {
    return _groups
        .where('memberIds', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                GroupModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  SEARCH
  // ════════════════════════════════════════════════════════════════════════════

  /// Kullanıcı ara (username veya isim ile, server-side prefix search)
  Future<List<UserModel>> searchUsers(String query) async {
    final uid = currentUid;
    if (uid == null) return [];

    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return [];

    debugPrint('[FriendService] searchUsers: "$normalized"');

    final endStr = '$normalized';

    try {
      // username ve name alanlarını paralel ara
      final snapshots = await Future.wait([
        _db
            .collection('users')
            .where('usernameLower', isGreaterThanOrEqualTo: normalized)
            .where('usernameLower', isLessThan: endStr)
            .limit(15)
            .get(),
        _db
            .collection('users')
            .where('nameLower', isGreaterThanOrEqualTo: normalized)
            .where('nameLower', isLessThan: endStr)
            .limit(15)
            .get(),
      ]);

      final seen = <String>{};
      final results = <UserModel>[];

      for (final snapshot in snapshots) {
        for (final doc in snapshot.docs) {
          if (seen.contains(doc.id)) continue;
          seen.add(doc.id);
          try {
            final user = UserModel.fromMap(doc.data());
            if (user.uid != uid) results.add(user);
          } catch (e) {
            debugPrint('UserModel parse hatası (${doc.id}): $e');
          }
        }
      }

      debugPrint('[FriendService] ${results.length} sonuç');
      return results.take(10).toList();
    } catch (e) {
      debugPrint('[FriendService] searchUsers hatası: $e');
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  FRIEND REQUESTS
  // ════════════════════════════════════════════════════════════════════════════

  Future<bool> areFriends(String uid1, String uid2) async {
    final doc = await _friends.doc(_friendshipId(uid1, uid2)).get();
    return doc.exists;
  }

  Future<bool> hasPendingRequest(String fromUid, String toUid) async {
    final snap = await _friendRequests
        .where('fromUid', isEqualTo: fromUid)
        .where('toUid', isEqualTo: toUid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Arkadaşlık isteği gönder.
  Future<void> sendFriendRequest(UserModel target) async {
    final uid = currentUid;
    if (uid == null) throw Exception('Oturum bulunamadı.');
    if (uid == target.uid) throw Exception('Kendine arkadaşlık isteği gönderemezsin.');

    if (await areFriends(uid, target.uid)) {
      throw Exception('Zaten arkadaşsınız.');
    }

    if (await hasPendingRequest(uid, target.uid)) {
      throw Exception('Zaten bekleyen bir isteğiniz var.');
    }

    final existingIn = await _friendRequests
        .where('fromUid', isEqualTo: target.uid)
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (existingIn.docs.isNotEmpty) {
      final request = FriendRequestModel.fromMap(
        existingIn.docs.first.data() as Map<String, dynamic>,
        existingIn.docs.first.id,
      );
      await acceptFriendRequest(request);
      return;
    }

    final myProfile = await _fetchCurrentUserProfile();

    await _friendRequests.add({
      'fromUid': uid,
      'toUid': target.uid,
      'fromUserId': uid,
      'toUserId': target.uid,
      'fromName': myProfile['name'] ?? '',
      'toName': target.name,
      'fromUsername': myProfile['username'] ?? '',
      'toUsername': target.username,
      'fromEmail': myProfile['email'] ?? '',
      'toEmail': target.email,
      'status': 'pending',
      'participants': [uid, target.uid],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _notifications.createNotification(
      userId: target.uid,
      title: 'Yeni arkadaşlık isteği',
      body: '${myProfile['name'] ?? 'Bir kullanıcı'} sana arkadaşlık isteği gönderdi.',
      type: AppNotificationType.info,
      data: {'fromUid': uid},
    );
  }

  /// Arkadaşlık isteğini kabul et.
  Future<void> acceptFriendRequest(FriendRequestModel request) async {
    final uid = currentUid;
    if (uid == null) throw Exception('Oturum bulunamadı.');
    if (uid != request.toUid) {
      throw Exception('Bu isteği yalnızca alıcı kullanıcı kabul edebilir.');
    }

    final friendshipId = _friendshipId(request.fromUid, request.toUid);

    final senderDoc = await _db.collection('users').doc(request.fromUid).get();
    final senderData = senderDoc.data() ?? {};
    final senderName = (senderData['name'] as String?)?.trim().isNotEmpty == true
        ? senderData['name'] as String
        : request.fromName;
    final senderUsername =
        (senderData['username'] as String?)?.trim().isNotEmpty == true
            ? senderData['username'] as String
            : request.fromUsername;
    final senderEmail = senderData['email'] as String? ?? '';

    final receiverDoc = await _db.collection('users').doc(request.toUid).get();
    final receiverData = receiverDoc.data() ?? {};
    final receiverName =
        (receiverData['name'] as String?)?.trim().isNotEmpty == true
            ? receiverData['name'] as String
            : request.toName;
    final receiverUsername =
        (receiverData['username'] as String?)?.trim().isNotEmpty == true
            ? receiverData['username'] as String
            : request.toUsername;
    final receiverEmail = receiverData['email'] as String? ?? '';

    final batch = _db.batch();

    batch.update(_friendRequests.doc(request.id), {
      'status': 'accepted',
      'respondedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_friends.doc(friendshipId), {
      'id': friendshipId,
      'users': [request.fromUid, request.toUid],
      'fromUserId': request.fromUid,
      'toUserId': request.toUid,
      'fromName': senderName,
      'toName': receiverName,
      'fromUsername': senderUsername,
      'toUsername': receiverUsername,
      'fromEmail': senderEmail,
      'toEmail': receiverEmail,
      'friendName': senderName,
      'friendUsername': senderUsername,
      'friendEmail': senderEmail,
      'createdAt': FieldValue.serverTimestamp(),
      'acceptedRequestId': request.id,
    }, SetOptions(merge: true));

    await batch.commit();

    await _notifications.createNotification(
      userId: request.fromUid,
      title: 'Arkadaşlık isteğin kabul edildi',
      body: '$receiverName arkadaşlık isteğini kabul etti.',
      type: AppNotificationType.info,
      data: {'friendUid': request.toUid},
    );
  }

  Future<void> rejectFriendRequest(String requestId) async {
    await _friendRequests.doc(requestId).update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  GROUPS
  // ════════════════════════════════════════════════════════════════════════════

  Future<GroupModel> createGroup(String name, List<FriendModel> members) async {
    final uid = currentUid;
    if (uid == null) throw 'Oturum bulunamadı.';
    final me = await _firestore.getUser(uid);
    if (me == null) throw 'Kullanıcı bilgin bulunamadı.';

    final memberIds = <String>{uid};
    final memberNames = <String, dynamic>{uid: me.name};

    for (final member in members) {
      final memberId = member.getOtherUid(uid);
      if (memberId != null && memberId.isNotEmpty) {
        memberIds.add(memberId);
        memberNames[memberId] = member.getOtherName(uid);
      }
    }

    final group = GroupModel(
      id: '',
      name: name.trim(),
      createdBy: uid,
      createdByName: me.name,
      memberIds: memberIds.toList(),
      memberNames: memberNames,
      createdAt: DateTime.now(),
    );

    final ref = await _groups.add(group.toMap());

    for (final memberId in memberIds.where((id) => id != uid)) {
      await _notifications.createNotification(
        userId: memberId,
        title: 'Yeni grup',
        body: '${me.name} seni ${group.name} grubuna ekledi.',
        type: AppNotificationType.info,
        data: {'groupId': ref.id},
      );
    }

    return GroupModel(
      id: ref.id,
      name: group.name,
      createdBy: group.createdBy,
      createdByName: group.createdByName,
      memberIds: group.memberIds,
      memberNames: group.memberNames,
      createdAt: group.createdAt,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  DEBT REQUESTS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> createDebtRequest({
    required UserModel target,
    required double amount,
    required String description,
    bool iOwe = true,
  }) async {
    final uid = currentUid;
    if (uid == null) throw 'Oturum bulunamadı.';
    final me = await _firestore.getUser(uid);
    if (me == null) throw 'Kullanıcı bilgin bulunamadı.';

    if (!await areFriends(uid, target.uid)) {
      throw 'Bu kişiye borç yazmak için önce arkadaş olmalısın.';
    }

    final tx = TransactionModel(
      id: '',
      fromUser: iOwe ? uid : target.uid,
      toUser: iOwe ? target.uid : uid,
      amount: amount,
      description: description,
      status: TransactionStatus.requested,
      createdAt: DateTime.now(),
      fromUserName: iOwe ? me.name : target.name,
      toUserName: iOwe ? target.name : me.name,
      createdBy: uid,
    );

    final ref = await _transactions.addTransaction(tx);

    await _notifications.createNotification(
      userId: target.uid,
      title: 'Borç onayı gerekiyor',
      body:
          '${me.name}, ${amount.toStringAsFixed(2)} ₺ tutarında borç kaydı gönderdi.',
      type: AppNotificationType.debtRequest,
      data: {'transactionId': ref.id},
    );
  }

  Future<void> createGroupDebtRequests({
    required GroupModel group,
    required double amount,
    required String description,
  }) async {
    final uid = currentUid;
    if (uid == null) throw 'Oturum bulunamadı.';
    final me = await _firestore.getUser(uid);
    if (me == null) throw 'Kullanıcı bilgin bulunamadı.';
    if (!group.memberIds.contains(uid)) throw 'Bu grupta değilsin.';

    for (final memberId in group.memberIds.where((id) => id != uid)) {
      if (!await areFriends(uid, memberId)) {
        throw 'Grup içindeki herkese borç yazmak için tüm üyeler arkadaşın olmalı.';
      }
      final targetName =
          group.memberNames[memberId]?.toString() ?? 'Kullanıcı';
      final tx = TransactionModel(
        id: '',
        fromUser: memberId,
        toUser: uid,
        amount: amount,
        description: description,
        status: TransactionStatus.requested,
        createdAt: DateTime.now(),
        fromUserName: targetName,
        toUserName: me.name,
        groupId: group.id,
        groupName: group.name,
        createdBy: uid,
      );
      final ref = await _transactions.addTransaction(tx);
      await _notifications.createNotification(
        userId: memberId,
        title: 'Grup borç isteği',
        body:
            '${group.name} grubunda ${amount.toStringAsFixed(2)} ₺ borç onayı bekliyor.',
        type: AppNotificationType.groupDebt,
        data: {'transactionId': ref.id, 'groupId': group.id},
      );
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════════════════════════════

  Future<Map<String, String>> _fetchCurrentUserProfile() async {
    final uid = currentUid;
    if (uid == null) throw Exception('Kullanıcı oturumu bulunamadı.');

    final userDoc = await _db.collection('users').doc(uid).get();
    final data = userDoc.data() ?? <String, dynamic>{};

    final username = (data['username'] as String?)?.trim() ?? '';
    final name = (data['name'] as String?)?.trim() ??
        _auth.currentUser?.displayName ??
        '';
    final email = (data['email'] as String?)?.trim() ??
        _auth.currentUser?.email ??
        '';

    if (username.isEmpty) throw Exception('Kullanıcı adı alınamadı.');

    return {'username': username, 'name': name, 'email': email};
  }

  List<FriendRequestModel> _mapRequests(QuerySnapshot snap) {
    return snap.docs
        .map((doc) => FriendRequestModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
