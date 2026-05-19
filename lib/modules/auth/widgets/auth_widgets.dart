import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AuthFormHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Gradient gradient;
  final IconData icon;

  const AuthFormHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 16),
        Text(title, style: AppTextStyles.headlineLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class AuthDivider extends StatelessWidget {
  final String text;
  const AuthDivider({super.key, this.text = 'veya'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text, style: AppTextStyles.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: AppTextStyles.bodyMedium),
        GestureDetector(
          onTap: onTap,
          child: Text(
            ' $linkText',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
