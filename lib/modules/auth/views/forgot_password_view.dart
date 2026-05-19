import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.forgotPasswordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(AppStrings.resetPassword, style: AppTextStyles.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'E-posta adresinizi girin, sifre sifirlama baglantisi gonderelim.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 36),
                AppTextField(
                  controller: controller.emailController,
                  label: AppStrings.email,
                  hint: AppStrings.hintEmail,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => controller.sendPasswordReset(),
                ),
                const SizedBox(height: 28),
                Obx(
                  () => AppButton(
                    label: AppStrings.resetPassword,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.sendPasswordReset,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: AppStrings.back,
                  variant: AppButtonVariant.ghost,
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
