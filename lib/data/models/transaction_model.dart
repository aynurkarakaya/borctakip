import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionStatus { requested, pending, paid, cancelled }

enum TransactionType { debt, receivable }

class TransactionModel {
  final String id;
  final String fromUser;
  final String toUser;
  final double amount;
  final String description;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? fromUserName;
  final String? toUserName;
  final String? groupId;
  final String? groupName;
  final String? createdBy;

  const TransactionModel({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
    this.fromUserName,
    this.toUserName,
    this.groupId,
    this.groupName,
    this.createdBy,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransactionModel(
      id: docId,
      fromUser: map['fromUser'] as String? ?? '',
      toUser: map['toUser'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] as String? ?? '',
      status: _statusFromString(map['status'] as String? ?? 'pending'),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      fromUserName: map['fromUserName'] as String?,
      toUserName: map['toUserName'] as String?,
      groupId: map['groupId'] as String?,
      groupName: map['groupName'] as String?,
      createdBy: map['createdBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUser': fromUser,
      'toUser': toUser,
      'amount': amount,
      'description': description,
      'status': _statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
      'fromUserName': fromUserName,
      'toUserName': toUserName,
      'groupId': groupId,
      'groupName': groupName,
      'createdBy': createdBy,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? fromUser,
    String? toUser,
    double? amount,
    String? description,
    TransactionStatus? status,
    DateTime? createdAt,
    String? fromUserName,
    String? toUserName,
    String? groupId,
    String? groupName,
    String? createdBy,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      fromUserName: fromUserName ?? this.fromUserName,
      toUserName: toUserName ?? this.toUserName,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  static TransactionStatus _statusFromString(String s) {
    switch (s) {
      case 'requested':
        return TransactionStatus.requested;
      case 'paid':
        return TransactionStatus.paid;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  static String _statusToString(TransactionStatus s) {
    switch (s) {
      case TransactionStatus.requested:
        return 'requested';
      case TransactionStatus.paid:
        return 'paid';
      case TransactionStatus.cancelled:
        return 'cancelled';
      default:
        return 'pending';
    }
  }
}
