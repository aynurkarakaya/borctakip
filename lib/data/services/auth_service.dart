import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../core/constants/app_strings.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isLoggedIn => _auth.currentUser != null;

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String username,
    String phone = '',
    String accountType = 'user',
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final cleanUsername = username.trim().toLowerCase();
      final cleanFullName = fullName.trim();

      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: cleanUsername)
          .limit(1)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        throw AppStrings.errorUsernameInUse;
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw AppStrings.errorGeneral;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': cleanFullName,
        'fullName': cleanFullName,
        'nameLower': cleanFullName.toLowerCase(),
        'username': cleanUsername,
        'usernameLower': cleanUsername,
        'email': cleanEmail,
        'phone': phone.trim(),
        'accountType': accountType,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      await user.updateDisplayName(cleanFullName);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AppStrings.errorEmailInUse;
      case 'wrong-password':
      case 'invalid-credential':
        return AppStrings.errorWrongPassword;
      case 'user-not-found':
        return AppStrings.errorUserNotFound;
      case 'weak-password':
        return AppStrings.errorWeakPassword;
      case 'invalid-email':
        return AppStrings.validationEmail;
      case 'too-many-requests':
        return 'Cok fazla istek. Lutfen daha sonra tekrar deneyin.';
      case 'network-request-failed':
        return AppStrings.errorNetwork;
      default:
        return AppStrings.errorGeneral;
    }
  }
}