import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.validationRequired;
    if (value.trim().length < 2) return 'Ad en az 2 karakter olmalidir';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.validationRequired;
    if (value.trim().length < 3) return AppStrings.validationUsernameMin;
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!regex.hasMatch(value.trim())) return AppStrings.validationUsernameChars;
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.validationRequired;
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w+$');
    if (!regex.hasMatch(value.trim())) return AppStrings.validationEmail;
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.validationRequired;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 11) return AppStrings.validationPhone;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.validationRequired;
    if (value.length < 6) return AppStrings.validationPasswordMin;
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return AppStrings.validationRequired;
    if (value != password) return AppStrings.validationPasswordMatch;
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.validationRequired;
    return null;
  }
}
