import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_text_styles.dart';
import '../controllers/receipt_controller.dart';

class ReceiptHistoryScreen extends StatefulWidget {
  const ReceiptHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptHistoryScreen> createState() => _ReceiptHistoryScreenState();
}

class _ReceiptHistoryScreenState extends State<ReceiptHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final ReceiptController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ReceiptController>();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiş Geçmişi'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Gönderilen'),
            Tab(text: 'Beklemede'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSentReceipts(),
          _buildPendingReceipts(),
        ],
      ),
    );
  }

  Widget _buildSentReceipts() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return _buildSkeletonLoader();
      }

      if (_controller.userReceipts.isEmpty) {
        return _buildEmptyState(
          icon: Icons.send,
          title: 'Henüz fiş göndermediniz',
          subtitle: 'Arkadaşlarınıza borç eklemek için fiş gönderin',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.userReceipts.length,
        itemBuilder: (context, index) {
          final receipt = _controller.userReceipts[index];
          return _buildReceiptCard(receipt);
        },
      );
    });
  }

  Widget _buildPendingReceipts() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return _buildSkeletonLoader();
      }

      if (_controller.pendingReceipts.isEmpty) {
        return _buildEmptyState(
          icon: Icons.inbox,
          title: 'Bekleyen fiş yok',
          subtitle: 'Tüm fişler onaylandı',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.pendingReceipts.length,
        itemBuilder: (context, index) {
          final receipt = _controller.pendingReceipts[index];
          return _buildReceiptCard(receipt, isPending: true);
        },
      );
    });
  }

  Widget _buildReceiptCard(
    dynamic receipt, {
    bool isPending = false,
  }) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');
    final statusColor = _getStatusColor(receipt.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showReceiptDetails(receipt),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receipt.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium(
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(receipt.createdAt),
                          style: AppTextStyles.bodySmall(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${receipt.amount.toStringAsFixed(2)} ₺',
                        style: AppTextStyles.headline6(
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusLabel(receipt.status),
                          style: AppTextStyles.bodySmall(
                            color: statusColor,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Recipient info
              if (receipt.toUserId != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Alıcı: ${receipt.toUserId}',
                      style: AppTextStyles.bodySmall(),
                    ),
                  ],
                ),
              ],

              // Action buttons if pending
              if (isPending && receipt.status == 'pending') ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _controller.deleteReceipt(receipt.id),
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Sil'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.headline6()),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.bodySmall()),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  void _showReceiptDetails(dynamic receipt) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fiş Detayları',
              style: AppTextStyles.headline6(weight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _detailRow('Açıklama', receipt.description),
            _detailRow('Tutar', '${receipt.amount.toStringAsFixed(2)} ₺'),
            _detailRow('Durum', _getStatusLabel(receipt.status)),
            if (receipt.toUserId != null)
              _detailRow('Alıcı', receipt.toUserId),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Kapat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall()),
          Text(value, style: AppTextStyles.bodySmall(weight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Onaylı';
      case 'rejected':
        return 'Reddedildi';
      case 'pending':
        return 'Beklemede';
      default:
        return status;
    }
  }
}
