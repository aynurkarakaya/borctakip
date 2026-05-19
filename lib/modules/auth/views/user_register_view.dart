import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class UserRegisterView extends GetView<AuthController> {
  const UserRegisterView({super.key});

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
            key: controller.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const AuthFormHeader(
                  title: AppStrings.registerTitle,
                  subtitle: AppStrings.registerSubtitle,
                  gradient: AppColors.userGradient,
                  icon: Icons.person_add_rounded,
                ),
                const SizedBox(height: 36),
                AppTextField(
                  controller: controller.nameController,
                  label: AppStrings.fullName,
                  hint: AppStrings.hintFullName,
                  prefixIcon: Icons.badge_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.name,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: controller.usernameController,
                  label: AppStrings.username,
                  hint: AppStrings.hintUsername,
                  prefixIcon: Icons.alternate_email_rounded,
                  validator: Validators.username,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                  ],
                ),
                const SizedBox(height: 16),
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
                AppTextField(
                  controller: controller.phoneController,
                  label: AppStrings.phone,
                  hint: AppStrings.hintPhone,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
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
                    textInputAction: TextInputAction.next,
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
                const SizedBox(height: 16),
                Obx(
                  () => AppTextField(
                    controller: controller.confirmPasswordController,
                    label: AppStrings.confirmPassword,
                    hint: AppStrings.hintPassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    validator: (v) => Validators.confirmPassword(
                      v,
                      controller.passwordController.text,
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => controller.registerUser(),
                    suffixWidget: GestureDetector(
                      onTap: controller.toggleConfirmPasswordVisibility,
                      child: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Obx(
                  () => AppButton(
                    label: AppStrings.register,
                    isLoading: controller.isLoading.value,
                    gradient: AppColors.userGradient,
                    onPressed: controller.registerUser,
                  ),
                ),
                const SizedBox(height: 24),
                AuthFooterLink(
                  text: AppStrings.alreadyHaveAccount,
                  linkText: AppStrings.login,
                  onTap: () {
                    controller.clearForm();
                    Get.offNamed(AppRoutes.userLogin);
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
