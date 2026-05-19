import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fiş Okuma',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.document_scanner_rounded,
                    color: Colors.white, size: 56),
              ),
              const SizedBox(height: 20),
              const Text('Fiş Okuma',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Kamera ile fiş fotoğrafı çekerek tutarı otomatik tanımlayabilirsin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _PickButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      source: ImageSource.camera,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      source: ImageSource.gallery,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final ImageSource source;

  const _PickButton({
    required this.icon,
    required this.label,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 20),
      label: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      onPressed: () async {
        final picker = ImagePicker();
        final img = await picker.pickImage(source: source);
        if (img != null) {
          Get.snackbar(
            'Fiş Seçildi',
            'OCR işlemi yakında eklenecek.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.info,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      },
    );
  }
}
