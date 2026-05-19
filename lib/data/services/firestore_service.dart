import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/cafe_model.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Expose Firestore instance for ad-hoc queries
  FirebaseFirestore get db => _db;

  CollectionReference get _users => _db.collection(AppConstants.usersCollection);
  CollectionReference get _cafes => _db.collection(AppConstants.cafesCollection);

  // ---- USER OPERATIONS ----

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<bool> isUsernameAvailableForUser(String username) async {
    final query = await _users
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  // ---- CAFE OPERATIONS ----

  Future<void> createCafe(CafeModel cafe) async {
    await _cafes.doc(cafe.uid).set(cafe.toMap());
  }

  Future<CafeModel?> getCafe(String uid) async {
    final doc = await _cafes.doc(uid).get();
    if (!doc.exists) return null;
    return CafeModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<bool> isUsernameAvailableForCafe(String username) async {
    final query = await _cafes
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  Future<void> updateCafe(String uid, Map<String, dynamic> data) async {
    await _cafes.doc(uid).update(data);
  }

  // ---- SHARED ----

  Future<String?> getAccountType(String uid) async {
    final userDoc = await _users.doc(uid).get();
    if (userDoc.exists) return AppConstants.accountTypeUser;
    final cafeDoc = await _cafes.doc(uid).get();
    if (cafeDoc.exists) return AppConstants.accountTypeCafe;
    return null;
  }
}
