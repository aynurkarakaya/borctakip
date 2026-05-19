import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/cafe_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Form Keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();

  // Text Controllers
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  // ---- USER AUTH ----

  Future<void> registerUser() async {
    if (!registerFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final username = usernameController.text.trim().toLowerCase();
      final isAvailable = await _firestoreService.isUsernameAvailableForUser(username);
      if (!isAvailable) {
        _showError(AppStrings.errorUsernameInUse);
        return;
      }

      final credential = await _authService.signUpWithEmail(
    email: emailController.text.trim(),
    password: passwordController.text,
    fullName: nameController.text.trim(),
    username: usernameController.text.trim(),
    phone: phoneController.text.trim(),
    accountType: AppConstants.accountTypeUser,
);
      final user = UserModel(
        uid: credential.user!.uid,
        name: nameController.text.trim(),
        username: username,
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        accountType: AppConstants.accountTypeUser,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createUser(user);
      _showSuccess(AppStrings.successRegister);
      Get.offAllNamed(AppRoutes.mainNav);
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginUser() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authService.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final uid = _authService.currentUser!.uid;
      final user = await _firestoreService.getUser(uid);

      if (user == null) {
        await _authService.signOut();
        _showError('Kullanici hesabi bulunamadi. Kafe hesabiniz varsa kafe girisi yapin.');
        return;
      }

      _showSuccess(AppStrings.successLogin);
      Get.offAllNamed(AppRoutes.mainNav);
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ---- CAFE AUTH ----

  Future<void> registerCafe() async {
    if (!registerFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final username = usernameController.text.trim().toLowerCase();
      final isAvailable = await _firestoreService.isUsernameAvailableForCafe(username);
      if (!isAvailable) {
        _showError(AppStrings.errorUsernameInUse);
        return;
      }

      final credential = await _authService.signUpWithEmail(
    email: emailController.text.trim(),
    password: passwordController.text,
    fullName: nameController.text.trim(),
    username: usernameController.text.trim(),
    phone: phoneController.text.trim(),
    accountType: AppConstants.accountTypeCafe,
);

      final cafe = CafeModel(
        uid: credential.user!.uid,
        name: nameController.text.trim(),
        username: username,
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        accountType: AppConstants.accountTypeCafe,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createCafe(cafe);
      _showSuccess(AppStrings.successRegister);
      Get.offAllNamed(AppRoutes.cafeHome);
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginCafe() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authService.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final uid = _authService.currentUser!.uid;
      final cafe = await _firestoreService.getCafe(uid);

      if (cafe == null) {
        await _authService.signOut();
        _showError('Kafe hesabi bulunamadi. Kullanici hesabiniz varsa kullanici girisi yapin.');
        return;
      }

      _showSuccess(AppStrings.successLogin);
      Get.offAllNamed(AppRoutes.cafeHome);
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ---- FORGOT PASSWORD ----

  Future<void> sendPasswordReset() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authService.sendPasswordResetEmail(emailController.text.trim());
      _showSuccess(AppStrings.resetPasswordSent);
      Get.back();
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ---- LOGOUT ----

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 40),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      _showSuccess(AppStrings.successLogout);
      Get.offAllNamed(AppRoutes.authSelection);
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Hata',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Basarili',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void clearForm() {
    nameController.clear();
    usernameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
