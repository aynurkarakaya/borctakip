import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/friend_service.dart';

class ManualEntryController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _firestore = Get.find<FirestoreService>();
  final _friendService = Get.find<FriendService>();

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  final isDebt = true.obs; // true = borç, false = alacak
  final isLoading = false.obs;

  void toggleType(bool debt) => isDebt.value = debt;

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final uid = _auth.currentUser?.uid ?? '';
      final targetUsername = usernameController.text.trim().toLowerCase().replaceAll('@', '');
      final snap = await _firestore.db
          .collection('users')
          .where('username', isEqualTo: targetUsername)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        Get.snackbar('Hata', 'Bu kullanıcı bulunamadı.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.debt,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12);
        return;
      }

      final target = UserModel.fromMap(snap.docs.first.data());
      if (target.uid == uid) {
        Get.snackbar('Hata', 'Kendine borç kaydı gönderemezsin.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.debt,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12);
        return;
      }

      await _friendService.createDebtRequest(
        target: target,
        amount: double.parse(amountController.text.replaceAll(',', '.')),
        description: descriptionController.text.trim(),
        iOwe: isDebt.value,
      );

      Get.back();
      Get.snackbar(
        'Onay isteği gönderildi',
        'Borç kaydı karşı taraf onayladıktan sonra aktifleşecek.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar('Hata', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.debt,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

class ManualEntryPage extends StatelessWidget {
  const ManualEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ManualEntryController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manuel Ekle',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: ctrl.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type selector
              Obx(() => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _TypeTab(
                          label: 'Ben borçluyum',
                          icon: Icons.trending_down_rounded,
                          selected: ctrl.isDebt.value,
                          color: AppColors.debt,
                          onTap: () => ctrl.toggleType(true),
                        ),
                        _TypeTab(
                          label: 'Bende alacak var',
                          icon: Icons.trending_up_rounded,
                          selected: !ctrl.isDebt.value,
                          color: AppColors.credit,
                          onTap: () => ctrl.toggleType(false),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 20),

              _SectionLabel(label: 'Kullanıcı Adı'),
              const SizedBox(height: 8),
              _StyledField(
                controller: ctrl.usernameController,
                hint: '@arkadas_kullanici_adi',
                icon: Icons.person_outline_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Kullanıcı adı gerekli' : null,
              ),

              const SizedBox(height: 16),

              _SectionLabel(label: 'Miktar (₺)'),
              const SizedBox(height: 8),
              _StyledField(
                controller: ctrl.amountController,
                hint: '0.00',
                icon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Miktar gerekli';
                  final d = double.tryParse(v.replaceAll(',', '.'));
                  if (d == null || d <= 0) return 'Geçerli bir miktar girin';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _SectionLabel(label: 'Açıklama (opsiyonel)'),
              const SizedBox(height: 8),
              _StyledField(
                controller: ctrl.descriptionController,
                hint: 'Akşam yemeği, market alışverişi...',
                icon: Icons.description_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 32),

              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: ctrl.isLoading.value ? null : ctrl.save,
                      child: ctrl.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('Kaydet',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;

  const _StyledField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textTertiary),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
