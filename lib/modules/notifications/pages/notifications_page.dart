import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/app_notification_model.dart';
import '../../../data/models/transaction_model.dart';
import '../controllers/notifications_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Bildirimler', style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          actions: [
            TextButton(onPressed: controller.markAllAsRead, child: const Text('Tümünü oku')),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [Tab(text: 'Bildirim'), Tab(text: 'Borç Onayı')],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<List<AppNotificationModel>>(
              stream: controller.notificationsStream,
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                if (items.isEmpty) return const Center(child: Text('Bildirim yok.'));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      onTap: () => controller.markAsRead(item.id),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: item.isRead ? AppColors.border : AppColors.primary.withOpacity(.3))),
                      leading: CircleAvatar(
                        backgroundColor: item.isRead ? AppColors.surfaceVariant : AppColors.primary.withOpacity(.1),
                        child: Icon(item.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded, color: item.isRead ? AppColors.textSecondary : AppColors.primary),
                      ),
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${item.body}\n${DateFormat('dd.MM.yyyy HH:mm').format(item.createdAt)}'),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
            StreamBuilder<List<TransactionModel>>(
              stream: controller.incomingDebtRequestsStream,
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                if (items.isEmpty) return const Center(child: Text('Onay bekleyen borç isteği yok.'));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final tx = items[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${tx.toUserName ?? 'Kullanıcı'} tarafından borç isteği', style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text('${tx.amount.toStringAsFixed(2)} ₺', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.debt)),
                          if (tx.groupName != null) Text('Grup: ${tx.groupName}', style: const TextStyle(color: AppColors.textSecondary)),
                          if (tx.description.isNotEmpty) Text(tx.description, style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: OutlinedButton(onPressed: () => controller.rejectDebt(tx), child: const Text('Reddet'))),
                              const SizedBox(width: 10),
                              Expanded(child: ElevatedButton(onPressed: () => controller.approveDebt(tx), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('Onayla'))),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
