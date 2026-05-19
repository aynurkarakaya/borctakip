import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String currentUid;
  final VoidCallback? onPay;
  final VoidCallback? onRemind;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currentUid,
    this.onPay,
    this.onRemind,
  });

  bool get isDebt => transaction.fromUser == currentUid;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);
    final dateFmt = DateFormat('d MMM yyyy', 'tr_TR');
    final color = isDebt ? AppColors.debt : AppColors.credit;
    final bgColor = isDebt ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
    final icon = isDebt ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
final statusLabel = switch (transaction.status) {
  TransactionStatus.requested => 'Onay Bekliyor',
  TransactionStatus.pending => 'Bekliyor',
  TransactionStatus.paid => 'Ödendi',
  TransactionStatus.cancelled => 'İptal',
};
final statusColor = switch (transaction.status) {
  TransactionStatus.requested => Colors.blueGrey,
  TransactionStatus.pending => Colors.orange,
  TransactionStatus.paid => Colors.green,
  TransactionStatus.cancelled => Colors.red,
};

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.isEmpty
                      ? 'İşlem'
                      : transaction.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  isDebt
                      ? '→ ${transaction.toUserName ?? transaction.toUser}'
                      : '← ${transaction.fromUserName ?? transaction.fromUser}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  dateFmt.format(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDebt ? '-' : '+'}${fmt.format(transaction.amount)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
