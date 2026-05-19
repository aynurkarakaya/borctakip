import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class CafeLoginView extends GetView<AuthController> {
  const CafeLoginView({super.key});

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const AuthFormHeader(
                  title: AppStrings.loginTitle,
                  subtitle: AppStrings.loginSubtitle,
                  gradient: AppColors.cafeGradient,
                  icon: Icons.coffee_rounded,
                ),
                const SizedBox(height: 36),
                AppTextField(
                  controller: controller.emailController,
                  label: AppStrings.email,
                  hint: AppStrings.hintEmail,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => AppTextField(
                    controller: controller.passwordController,
                    label: AppStrings.password,
                    hint: AppStrings.hintPassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !controller.isPasswordVisible.value,
                    validator: Validators.password,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => controller.loginCafe(),
                    suffixWidget: GestureDetector(
                      onTap: controller.togglePasswordVisibility,
                      child: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                    child: const Text(AppStrings.forgotPassword),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => AppButton(
                    label: AppStrings.login,
                    isLoading: controller.isLoading.value,
                    gradient: AppColors.cafeGradient,
                    onPressed: controller.loginCafe,
                  ),
                ),
                const SizedBox(height: 24),
                AuthFooterLink(
                  text: AppStrings.dontHaveAccount,
                  linkText: AppStrings.register,
                  onTap: () {
                    controller.clearForm();
                    Get.offNamed(AppRoutes.cafeRegister);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
