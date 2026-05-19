import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/group_model.dart';
import '../controllers/groups_controller.dart';

class GroupDetailsPage extends StatelessWidget {
  final GroupModel group;
  const GroupDetailsPage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupDetailsController());
    final memberNames = group.memberNames.values.map((e) => e.toString()).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Üyeler', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: memberNames.map((name) => Chip(label: Text(name), backgroundColor: AppColors.surfaceVariant)).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gruba borç yaz', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Seçilen tutar, gruptaki diğer üyelere ayrı ayrı onay isteği olarak gider.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: controller.amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                    validator: (value) {
                      final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) return 'Geçerli tutar gir';
                      return null;
                    },
                    decoration: InputDecoration(hintText: 'Tutar ₺', filled: true, fillColor: AppColors.surfaceVariant, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller.descriptionController,
                    decoration: InputDecoration(hintText: 'Açıklama', filled: true, fillColor: AppColors.surfaceVariant, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 14),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isSaving.value ? null : () => controller.sendGroupDebt(group),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          child: controller.isSaving.value ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Borç isteği gönder'),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
