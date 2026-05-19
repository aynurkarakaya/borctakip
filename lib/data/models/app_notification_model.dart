import 'package:cloud_firestore/cloud_firestore.dart';

enum AppNotificationType { friendRequest, friendAccepted, debtRequest, debtApproved, groupDebt, info }

class AppNotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final AppNotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  const AppNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.data,
  });

  factory AppNotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return AppNotificationModel(
      id: docId,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: _typeFromString(map['type'] as String? ?? 'info'),
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      data: Map<String, dynamic>.from(map['data'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': _typeToString(type),
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'data': data,
    };
  }

  static AppNotificationType _typeFromString(String value) {
    switch (value) {
      case 'friendRequest':
        return AppNotificationType.friendRequest;
      case 'friendAccepted':
        return AppNotificationType.friendAccepted;
      case 'debtRequest':
        return AppNotificationType.debtRequest;
      case 'debtApproved':
        return AppNotificationType.debtApproved;
      case 'groupDebt':
        return AppNotificationType.groupDebt;
      default:
        return AppNotificationType.info;
    }
  }

  static String _typeToString(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.friendRequest:
        return 'friendRequest';
      case AppNotificationType.friendAccepted:
        return 'friendAccepted';
      case AppNotificationType.debtRequest:
        return 'debtRequest';
      case AppNotificationType.debtApproved:
        return 'debtApproved';
      case AppNotificationType.groupDebt:
        return 'groupDebt';
      case AppNotificationType.info:
        return 'info';
    }
  }
}
