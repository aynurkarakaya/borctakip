import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../controllers/receipt_controller.dart';

class ReceiptCaptureScreen extends StatefulWidget {
  const ReceiptCaptureScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptCaptureScreen> createState() => _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends State<ReceiptCaptureScreen>
    with SingleTickerProviderStateMixin {
  late final ReceiptController _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ReceiptController>();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiş Ekle'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (_controller.selectedImage.value != null &&
            _controller.ocrResult.value == null &&
            _controller.isProcessing.value) {
          return _buildProcessingState(isDark);
        }

        if (_controller.selectedImage.value != null &&
            _controller.ocrResult.value != null) {
          return _buildOcrResultState(isDark);
        }

        return _buildInitialState(isDark);
      }),
    );
  }

  Widget _buildInitialState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Fişi çekin veya galerinizden seçin',
                    style: AppTextStyles.bodySmall(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Camera Button
          _buildActionButton(
            icon: Icons.camera_alt,
            label: 'Kamera ile Çek',
            onPressed: _controller.captureReceiptImage,
            isPrimary: true,
          ),
          const SizedBox(height: 12),

          // Gallery Button
          _buildActionButton(
            icon: Icons.image,
            label: 'Galeriden Seç',
            onPressed: _controller.pickReceiptImage,
            isPrimary: false,
          ),
          const SizedBox(height: 32),

          // Information cards
          _buildInfoCard(
            title: 'İpuçları',
            items: [
              'Işık kaynağını iyi konumlandırın',
              'Fişin tüm kısımlarını görünür kılın',
              'Net ve berrak resim çekiniz',
            ],
            icon: Icons.lightbulb_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Fiş taranıyor...',
            style: AppTextStyles.headline5(),
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen bekleyiniz',
            style: AppTextStyles.bodySmall(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOcrResultState(bool isDark) {
    final result = _controller.ocrResult.value!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preview image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _controller.selectedImage.value!,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),

          // Amount field
          _buildTextField(
            label: 'Tutar (TL)',
            controller: _controller.amountController,
            keyboardType: TextInputType.number,
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 16),

          // Description field
          _buildTextField(
            label: 'Açıklama',
            controller: _controller.descriptionController,
            icon: Icons.description,
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          // Error message
          Obx(() {
            if (_controller.errorMessage.value != null) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  _controller.errorMessage.value!,
                  style: AppTextStyles.bodySmall(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 24),

          // Action buttons
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _controller.isLoading.value ? null : _submitReceipt,
              icon: const Icon(Icons.check),
              label: _controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Gönder'),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _controller.clearImage,
              icon: const Icon(Icons.refresh),
              label: const Text('Yeni Fiş Çek'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          foregroundColor: isPrimary ? Colors.white : Colors.black,
        ),
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: AppTextStyles.bodyMedium(
            color: isPrimary ? Colors.white : Colors.black,
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<String> items,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium(weight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.bodySmall(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitReceipt() async {
    // TODO: Get current user ID and recipients
    // _controller.submitReceipt(currentUserId);
  }
}
