import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_text_styles.dart';
import '../controllers/receipt_controller.dart';

class ReceiptApprovalsScreen extends StatefulWidget {
  const ReceiptApprovalsScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptApprovalsScreen> createState() => _ReceiptApprovalsScreenState();
}

class _ReceiptApprovalsScreenState extends State<ReceiptApprovalsScreen> {
  late final ReceiptController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ReceiptController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiş Onayları'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return _buildSkeletonLoader();
        }

        if (_controller.pendingApprovals.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.pendingApprovals.length,
          itemBuilder: (context, index) {
            final approval = _controller.pendingApprovals[index];
            return _buildApprovalCard(approval, context);
          },
        );
      }),
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
            margin: const EdgeInsets.only(bottom: 16),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Onay bekleyen fiş yok',
            style: AppTextStyles.headline6(),
          ),
          const SizedBox(height: 8),
          Text(
            'Arkadaşlarınız size fiş gönderdikçe burada görüntülenecek',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(
    dynamic approval,
    BuildContext context,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Borç Onayı Gerekli',
                        style: AppTextStyles.bodyMedium(
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        approval.createdBy,
                        style: AppTextStyles.bodySmall(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Beklemede',
                  style: AppTextStyles.bodySmall(
                    color: Colors.orange,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _controller.rejectReceipt(approval.id, approval.receiptId),
                      icon: const Icon(Icons.close),
                      label: const Text('Reddet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _controller.approveReceipt(approval.id, approval.receiptId),
                      icon: const Icon(Icons.check),
                      label: const Text('Onayla'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
