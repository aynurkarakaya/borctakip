import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendRequestStatus { pending, accepted, rejected, cancelled }

class FriendRequestModel {
  final String id;
  final String fromUid;
  final String toUid;
  final String fromName;
  final String toName;
  final String fromUsername;
  final String toUsername;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  String get fromUserId => fromUid;
  String get toUserId => toUid;

  const FriendRequestModel({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.fromName,
    required this.toName,
    required this.fromUsername,
    required this.toUsername,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory FriendRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return FriendRequestModel(
      id: docId,
      fromUid: map['fromUid'] as String? ?? map['fromUserId'] as String? ?? '',
      toUid: map['toUid'] as String? ?? map['toUserId'] as String? ?? '',
      fromName: map['fromName'] as String? ?? '',
      toName: map['toName'] as String? ?? '',
      fromUsername: map['fromUsername'] as String? ?? '',
      toUsername: map['toUsername'] as String? ?? '',
      status: _statusFromString(map['status'] as String? ?? 'pending'),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      respondedAt: map['respondedAt'] is Timestamp
          ? (map['respondedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUid': fromUid,
      'toUid': toUid,
      'fromUserId': fromUid,
      'toUserId': toUid,
      'fromName': fromName,
      'toName': toName,
      'fromUsername': fromUsername,
      'toUsername': toUsername,
      'status': _statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt == null ? null : Timestamp.fromDate(respondedAt!),
      'participants': [fromUid, toUid],
    };
  }

  static FriendRequestStatus _statusFromString(String value) {
    switch (value) {
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      case 'cancelled':
        return FriendRequestStatus.cancelled;
      default:
        return FriendRequestStatus.pending;
    }
  }

  static String _statusToString(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.accepted:
        return 'accepted';
      case FriendRequestStatus.rejected:
        return 'rejected';
      case FriendRequestStatus.cancelled:
        return 'cancelled';
      case FriendRequestStatus.pending:
        return 'pending';
    }
  }
}
