import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptModel {
  final String id;
  final String createdBy;
  final String? fromUserId;
  final String? toUserId;
  final String? groupId;
  final double amount;
  final String description;
  final String? imageUrl;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final DateTime? approvedAt;
  final List<String> participants;
  final Map<String, dynamic>? ocrData;

  ReceiptModel({
    required this.id,
    required this.createdBy,
    this.fromUserId,
    this.toUserId,
    this.groupId,
    required this.amount,
    required this.description,
    this.imageUrl,
    this.status = 'pending',
    required this.createdAt,
    this.approvedAt,
    required this.participants,
    this.ocrData,
  });

  factory ReceiptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReceiptModel(
      id: doc.id,
      createdBy: data['createdBy'] ?? '',
      fromUserId: data['fromUserId'],
      toUserId: data['toUserId'],
      groupId: data['groupId'],
      amount: (data['amount'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      participants: List<String>.from(data['participants'] ?? []),
      ocrData: data['ocrData'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdBy': createdBy,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'groupId': groupId,
      'amount': amount,
      'description': description,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'participants': participants,
      'ocrData': ocrData,
    };
  }

  ReceiptModel copyWith({
    String? id,
    String? createdBy,
    String? fromUserId,
    String? toUserId,
    String? groupId,
    double? amount,
    String? description,
    String? imageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? approvedAt,
    List<String>? participants,
    Map<String, dynamic>? ocrData,
  }) {
    return ReceiptModel(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      groupId: groupId ?? this.groupId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      participants: participants ?? this.participants,
      ocrData: ocrData ?? this.ocrData,
    );
  }
}

class OcrResult {
  final double? amount;
  final String? description;
  final String rawText;
  final double confidence;

  OcrResult({
    required this.amount,
    required this.description,
    required this.rawText,
    this.confidence = 0.0,
  });

  bool get isValid => amount != null && description != null && amount! > 0;
}

class ReceiptApproval {
  final String id;
  final String createdBy;
  final String approverId;
  final String receiptId;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final DateTime? respondedAt;

  ReceiptApproval({
    required this.id,
    required this.createdBy,
    required this.approverId,
    required this.receiptId,
    this.status = 'pending',
    required this.createdAt,
    this.respondedAt,
  });

  factory ReceiptApproval.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReceiptApproval(
      id: doc.id,
      createdBy: data['createdBy'] ?? '',
      approverId: data['approverId'] ?? '',
      receiptId: data['receiptId'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdBy': createdBy,
      'approverId': approverId,
      'receiptId': receiptId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }
}
