import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../controllers/receipt_controller.dart';

class ReceiptConfirmationScreen extends StatefulWidget {
  const ReceiptConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptConfirmationScreen> createState() =>
      _ReceiptConfirmationScreenState();
}

class _ReceiptConfirmationScreenState extends State<ReceiptConfirmationScreen> {
  late final ReceiptController _controller;
  List<Map<String, String>> _friends = [];
  List<Map<String, String>> _groups = [];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ReceiptController>();
    _loadFriendsAndGroups();
  }

  void _loadFriendsAndGroups() {
    // TODO: Fetch from controller or repository
    _friends = [
      {'uid': '1', 'name': 'Ahmet'},
      {'uid': '2', 'name': 'Fatma'},
    ];
    _groups = [
      {'id': 'group1', 'name': 'Ofis Arkadaşları'},
      {'id': 'group2', 'name': 'Ev Arkadaşları'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiş Onayı'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            _buildRecipientSection(),
            const SizedBox(height: 24),
            _buildGroupSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fiş Özeti',
              style: AppTextStyles.bodyMedium(weight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tutar:',
                  style: AppTextStyles.bodySmall(),
                ),
                Obx(() => Text(
                  '${_controller.amountController.text} TL',
                  style: AppTextStyles.headline6(weight: FontWeight.w600),
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Açıklama:',
                  style: AppTextStyles.bodySmall(),
                ),
                Expanded(
                  child: Obx(() => Text(
                    _controller.descriptionController.text,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall(),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alıcı Seç',
          style: AppTextStyles.bodyMedium(weight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _friends.length,
            itemBuilder: (context, index) {
              final friend = _friends[index];
              return Obx(() {
                final isSelected = _controller.selectedRecipient.value?['uid'] ==
                    friend['uid'];
                return ListTile(
                  onTap: () {
                    _controller.selectRecipient(friend['uid']!, friend['name']!);
                  },
                  leading: CircleAvatar(
                    child: Text(friend['name']![0]),
                  ),
                  title: Text(friend['name']!),
                  trailing: isSelected
                      ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  )
                      : Icon(
                    Icons.circle_outlined,
                    color: Colors.grey[400],
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grup Seç (Opsiyonel)',
          style: AppTextStyles.bodyMedium(weight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (_groups.isEmpty)
          Text(
            'Henüz grup oluşturmadınız',
            style: AppTextStyles.bodySmall(color: Colors.grey),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                return Obx(() {
                  final isSelected =
                      _controller.selectedGroup.value == group['id'];
                  return ListTile(
                    onTap: () {
                      _controller.selectGroup(group['id']!);
                    },
                    leading: Icon(
                      Icons.group,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(group['name']!),
                    trailing: isSelected
                        ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    )
                        : Icon(
                      Icons.circle_outlined,
                      color: Colors.grey[400],
                    ),
                  );
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: Obx(() => ElevatedButton.icon(
            onPressed: _controller.isLoading.value ? null : _confirmReceipt,
            icon: const Icon(Icons.send),
            label: _controller.isLoading.value
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text('Onayla ve Gönder'),
          )),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.edit),
            label: const Text('Düzenle'),
          ),
        ),
      ],
    );
  }

  void _confirmReceipt() {
    // TODO: Get current user ID from auth service
    // _controller.submitReceipt(currentUserId);
  }
}
