import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/transaction_model.dart';

class TransactionRepository extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _transactions => _db.collection('transactions');

  // ── Streams ──────────────────────────────────────────────────────────────

  /// Kullanıcının borçları (fromUser == uid, pending)
  Stream<List<TransactionModel>> debtStream(String uid) {
    return _transactions
        .where('fromUser', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapDocs);
  }

  /// Kullanıcının alacakları (toUser == uid, pending)
  Stream<List<TransactionModel>> receivableStream(String uid) {
    return _transactions
        .where('toUser', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapDocs);
  }

  /// Tüm işlemler (hem borç hem alacak)
  Stream<List<TransactionModel>> allTransactionsStream(String uid) {
    // Firestore'da OR sorgusu yok; iki stream birleştirilir controller'da
    return _transactions
        .where('fromUser', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapDocs);
  }

  Stream<List<TransactionModel>> receivedTransactionsStream(String uid) {
    return _transactions
        .where('toUser', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapDocs);
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  Future<DocumentReference> addTransaction(TransactionModel tx) async {
    return _transactions.add(tx.toMap());
  }

  Stream<List<TransactionModel>> incomingDebtRequestsStream(String uid) {
    return _transactions
        .where('fromUser', isEqualTo: uid)
        .where('status', isEqualTo: 'requested')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapDocs);
  }

  Stream<List<TransactionModel>> sentDebtRequestsStream(String uid) {
    return _transactions
        .where('createdBy', isEqualTo: uid)
        .where('status', isEqualTo: 'requested')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapDocs);
  }

  Future<void> approveTransaction(String txId) async {
    await _transactions.doc(txId).update({'status': 'pending'});
  }

  Future<void> markAsPaid(String txId) async {
    await _transactions.doc(txId).update({'status': 'paid'});
  }

  Future<void> cancelTransaction(String txId) async {
    await _transactions.doc(txId).update({'status': 'cancelled'});
  }

  Future<void> deleteTransaction(String txId) async {
    await _transactions.doc(txId).delete();
  }

  // ── Summary ───────────────────────────────────────────────────────────────

  Future<double> getTotalDebt(String uid) async {
    final snap = await _transactions
        .where('fromUser', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();
    return snap.docs.fold<double>(
      0,
      (sum, doc) => sum + ((doc.data() as Map<String, dynamic>)['amount'] as num).toDouble(),
    );
  }

  Future<double> getTotalReceivable(String uid) async {
    final snap = await _transactions
        .where('toUser', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();
    return snap.docs.fold<double>(
      0,
      (sum, doc) => sum + ((doc.data() as Map<String, dynamic>)['amount'] as num).toDouble(),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<TransactionModel> _mapDocs(QuerySnapshot snap) {
    return snap.docs
        .map((d) => TransactionModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }
}
