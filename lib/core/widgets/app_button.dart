import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? prefixIcon;
  final double? width;
  final double height;
  final Gradient? gradient;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.prefixIcon,
    this.width,
    this.height = 56,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    if (gradient != null) {
      return _GradientButton(
        label: label,
        onPressed: isLoading ? null : onPressed,
        isLoading: isLoading,
        gradient: gradient!,
        prefixIcon: prefixIcon,
        width: width,
        height: height,
      );
    }

    switch (variant) {
      case AppButtonVariant.outline:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(),
          ),
        );
      case AppButtonVariant.ghost:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(color: AppColors.primary),
          ),
        );
      default:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(color: AppColors.textInverse),
          ),
        );
    }
  }

  Widget _buildChild({Color? color}) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.textInverse,
          ),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: 20, color: color),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTextStyles.buttonText.copyWith(color: color),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient gradient;
  final IconData? prefixIcon;
  final double? width;
  final double height;

  const _GradientButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.gradient,
    this.prefixIcon,
    this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? const LinearGradient(colors: [Color(0xFFCBD5E1), Color(0xFFCBD5E1)])
              : gradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(prefixIcon, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.buttonText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
