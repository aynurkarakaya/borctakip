import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/receipt_model.dart';

class ReceiptRepository {
  final FirebaseFirestore _firestore;

  ReceiptRepository(this._firestore);

  Future<ReceiptModel> createReceipt(ReceiptModel receipt) async {
    final receiptId = receipt.id.isEmpty ? const Uuid().v4() : receipt.id;
    final receiptWithId = receipt.copyWith(id: receiptId);
    
    await _firestore.collection('receipts').doc(receiptId).set(
      receiptWithId.toFirestore(),
    );

    return receiptWithId;
  }

  Future<void> updateReceipt(ReceiptModel receipt) async {
    await _firestore.collection('receipts').doc(receipt.id).update(
      receipt.toFirestore(),
    );
  }

  Future<ReceiptModel?> getReceipt(String receiptId) async {
    try {
      final doc = await _firestore.collection('receipts').doc(receiptId).get();
      if (!doc.exists) return null;
      return ReceiptModel.fromFirestore(doc);
    } catch (e) {
      throw ReceiptRepositoryException('Fiş getirilemedi: $e');
    }
  }

  Future<List<ReceiptModel>> getUserReceipts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('receipts')
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map(ReceiptModel.fromFirestore).toList();
    } catch (e) {
      throw ReceiptRepositoryException('Fişler getirilemedi: $e');
    }
  }

  Future<List<ReceiptModel>> getReceivedReceipts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('receipts')
          .where('participants', arrayContains: userId)
          .where('createdBy', isNotEqualTo: userId)
          .orderBy('createdBy')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map(ReceiptModel.fromFirestore).toList();
    } catch (e) {
      throw ReceiptRepositoryException('Alınan fişler getirilemedi: $e');
    }
  }

  Future<List<ReceiptModel>> getPendingReceipts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('receipts')
          .where('status', isEqualTo: 'pending')
          .where('participants', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map(ReceiptModel.fromFirestore).toList();
    } catch (e) {
      throw ReceiptRepositoryException('Bekleyen fişler getirilemedi: $e');
    }
  }

  Future<void> deleteReceipt(String receiptId) async {
    try {
      await _firestore.collection('receipts').doc(receiptId).delete();
    } catch (e) {
      throw ReceiptRepositoryException('Fiş silinemedi: $e');
    }
  }

  Stream<List<ReceiptModel>> watchUserReceipts(String userId) {
    return _firestore
        .collection('receipts')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ReceiptModel.fromFirestore).toList())
        .handleError((e) {
      throw ReceiptRepositoryException('Fişler izlenemedi: $e');
    });
  }

  Stream<List<ReceiptModel>> watchPendingReceipts(String userId) {
    return _firestore
        .collection('receipts')
        .where('status', isEqualTo: 'pending')
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ReceiptModel.fromFirestore).toList())
        .handleError((e) {
      throw ReceiptRepositoryException('Bekleyen fişler izlenemedi: $e');
    });
  }
}

class ReceiptApprovalRepository {
  final FirebaseFirestore _firestore;

  ReceiptApprovalRepository(this._firestore);

  Future<ReceiptApproval> createApproval(ReceiptApproval approval) async {
    final approvalId = const Uuid().v4();
    final approvalWithId = approval.copyWith(id: approvalId);

    await _firestore.collection('receipt_approvals').doc(approvalId).set(
      approvalWithId.toFirestore(),
    );

    return approvalWithId;
  }

  Future<void> approveReceipt(String approvalId, String receiptId) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore.collection('receipt_approvals').doc(approvalId),
        {
          'status': 'approved',
          'respondedAt': Timestamp.now(),
        },
      );

      batch.update(
        _firestore.collection('receipts').doc(receiptId),
        {
          'status': 'approved',
          'approvedAt': Timestamp.now(),
        },
      );

      await batch.commit();
    } catch (e) {
      throw ReceiptRepositoryException('Fiş onaylanamadı: $e');
    }
  }

  Future<void> rejectReceipt(String approvalId, String receiptId) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore.collection('receipt_approvals').doc(approvalId),
        {
          'status': 'rejected',
          'respondedAt': Timestamp.now(),
        },
      );

      batch.update(
        _firestore.collection('receipts').doc(receiptId),
        {
          'status': 'rejected',
        },
      );

      await batch.commit();
    } catch (e) {
      throw ReceiptRepositoryException('Fiş reddedilemedi: $e');
    }
  }

  Future<List<ReceiptApproval>> getPendingApprovals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('receipt_approvals')
          .where('status', isEqualTo: 'pending')
          .where('approverId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map(ReceiptApproval.fromFirestore).toList();
    } catch (e) {
      throw ReceiptRepositoryException('Onay bekleyen fişler getirilemedi: $e');
    }
  }

  Stream<List<ReceiptApproval>> watchPendingApprovals(String userId) {
    return _firestore
        .collection('receipt_approvals')
        .where('status', isEqualTo: 'pending')
        .where('approverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ReceiptApproval.fromFirestore).toList())
        .handleError((e) {
      throw ReceiptRepositoryException('Onay bekleyen fişler izlenemedi: $e');
    });
  }
}

extension on ReceiptApproval {
  ReceiptApproval copyWith({
    String? id,
    String? createdBy,
    String? approverId,
    String? receiptId,
    String? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return ReceiptApproval(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      approverId: approverId ?? this.approverId,
      receiptId: receiptId ?? this.receiptId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

class ReceiptRepositoryException implements Exception {
  final String message;
  ReceiptRepositoryException(this.message);

  @override
  String toString() => message;
}
