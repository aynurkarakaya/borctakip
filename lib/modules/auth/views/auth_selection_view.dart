import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AuthSelectionView extends StatelessWidget {
  const AuthSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildAccountTypeCard(
                context: context,
                gradient: AppColors.userGradient,
                icon: Icons.person_rounded,
                title: AppStrings.userAccount,
                description: AppStrings.userAccountDesc,
                features: const [
                  'Kisisel borc ve alacak',
                  'Arkadaslarla hesaplasma',
                  'Harcama takibi',
                ],
                onLoginTap: () => Get.toNamed(AppRoutes.userLogin),
                onRegisterTap: () => Get.toNamed(AppRoutes.userRegister),
              ),
              const SizedBox(height: 16),
              _buildAccountTypeCard(
                context: context,
                gradient: AppColors.cafeGradient,
                icon: Icons.coffee_rounded,
                title: AppStrings.cafeAccount,
                description: AppStrings.cafeAccountDesc,
                features: const [
                  'Musteri veresiye yonetimi',
                  'Hesap ozeti',
                  'Bildirim sistemi',
                ],
                onLoginTap: () => Get.toNamed(AppRoutes.cafeLogin),
                onRegisterTap: () => Get.toNamed(AppRoutes.cafeRegister),
              ),
              const Spacer(),
              _buildFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 20),
        Text(AppStrings.appName, style: AppTextStyles.displayMedium),
        const SizedBox(height: 6),
        Text(
          AppStrings.selectAccountType,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildAccountTypeCard({
    required BuildContext context,
    required Gradient gradient,
    required IconData icon,
    required String title,
    required String description,
    required List<String> features,
    required VoidCallback onLoginTap,
    required VoidCallback onRegisterTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(f, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onLoginTap,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(AppStrings.login),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onRegisterTap,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(AppStrings.register),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Verileriniz guvenle saklanir',
        style: AppTextStyles.bodySmall,
      ),
    );
  }
}
