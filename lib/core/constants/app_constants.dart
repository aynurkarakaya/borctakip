class AppConstants {
  AppConstants._();

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String cafesCollection = 'cafes';
  static const String transactionsCollection = 'transactions';

  // Account Types
  static const String accountTypeUser = 'user';
  static const String accountTypeCafe = 'cafe';

  // SharedPreferences Keys
  static const String prefAccountType = 'account_type';
  static const String prefOnboardingDone = 'onboarding_done';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxUsernameLength = 30;

  // UI
  static const double borderRadius = 16.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 24.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Animation
  static const int animDurationFast = 200;
  static const int animDurationMedium = 300;
  static const int animDurationSlow = 500;
  static const int splashDuration = 2500;
}
