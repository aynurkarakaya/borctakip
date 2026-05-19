// lib/data/models/friend_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendModel {
  final String id;
  final String? ownerUid;
  final String? friendUid;
  final String friendName;
  final String friendUsername;
  final String friendEmail;
  final DateTime createdAt;
  final List<String>? users;
  final String? fromUserId;
  final String? toUserId;
  final String? fromName;
  final String? toName;
  final String? fromUsername;
  final String? toUsername;

  const FriendModel({
    required this.id,
    this.ownerUid,
    this.friendUid,
    required this.friendName,
    required this.friendUsername,
    required this.friendEmail,
    required this.createdAt,
    this.users,
    this.fromUserId,
    this.toUserId,
    this.fromName,
    this.toName,
    this.fromUsername,
    this.toUsername,
  });

  /// Mevcut kullanıcı için karşı tarafın adını döndürür.
  String getOtherName(String currentUid) {
    if (fromUserId == currentUid) return toName ?? friendName;
    if (toUserId == currentUid) return fromName ?? friendName;
    return friendName;
  }

  /// Mevcut kullanıcı için karşı tarafın kullanıcı adını döndürür.
  String getOtherUsername(String currentUid) {
    if (fromUserId == currentUid) return toUsername ?? friendUsername;
    if (toUserId == currentUid) return fromUsername ?? friendUsername;
    return friendUsername;
  }

  /// Karşı tarafın uid'si
  String? getOtherUid(String currentUid) {
    if (users != null) {
      return users!.firstWhere((uid) => uid != currentUid,
          orElse: () => '');
    }
    if (fromUserId == currentUid) return toUserId;
    if (toUserId == currentUid) return fromUserId;
    return friendUid;
  }

  factory FriendModel.fromMap(Map<String, dynamic> map, String docId) {
    final usersList = (map['users'] as List<dynamic>?)?.cast<String>() ?? [];

    return FriendModel(
      id: docId,
      ownerUid: map['ownerUid'] as String?,
      friendUid: map['friendUid'] as String?,
      friendName: map['friendName'] as String? ?? '',
      friendUsername: map['friendUsername'] as String? ?? '',
      friendEmail: map['friendEmail'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      users: usersList.isNotEmpty ? usersList : null,
      fromUserId: map['fromUserId'] as String?,
      toUserId: map['toUserId'] as String?,
      fromName: map['fromName'] as String?,
      toName: map['toName'] as String?,
      fromUsername: map['fromUsername'] as String?,
      toUsername: map['toUsername'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'friendUid': friendUid,
      'friendName': friendName,
      'friendUsername': friendUsername,
      'friendEmail': friendEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'users': users,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'fromName': fromName,
      'toName': toName,
      'fromUsername': fromUsername,
      'toUsername': toUsername,
    };
  }
}
