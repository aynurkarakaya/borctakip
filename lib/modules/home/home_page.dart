import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../core/routes/app_routes.dart';
import '../debt/debt_page.dart';
import '../receivable/receivable_page.dart';
import '../qr/qr_page.dart';
import '../receipt/receipt_page.dart';
import '../manual_entry/manual_entry_page.dart';
import '../notifications/widgets/notification_badge.dart';

class HomeController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _firestore = Get.find<FirestoreService>();
  final _txRepo = Get.find<TransactionRepository>();

  final userName = ''.obs;
  final totalDebt = 0.0.obs;
  final totalReceivable = 0.0.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    _listenTotals();
  }

  Future<void> _loadUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final user = await _firestore.getUser(uid);
    if (user != null) userName.value = user.name;
  }

  void _listenTotals() {
    final uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    _txRepo.debtStream(uid).listen((list) {
      totalDebt.value = list.fold(0, (sum, t) => sum + t.amount);
    });

    _txRepo.receivableStream(uid).listen((list) {
      totalReceivable.value = list.fold(0, (sum, t) => sum + t.amount);
      isLoading.value = false;
    });
  }

  String get currentUid => _auth.currentUser?.uid ?? '';
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HomeController());
    final fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Borcum',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Obx(() => Text(
                                  ctrl.userName.value.isEmpty
                                      ? 'Hoş geldin 👋'
                                      : 'Hoş geldin, ${ctrl.userName.value} 👋',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                )),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(iconTheme: const IconThemeData(color: Colors.white)),
                            child: const NotificationBadgeButton(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Quick Action Cards ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hızlı İşlemler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _QuickActionCard(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'QR\nİşlemleri',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: () => Get.to(() => const QrPage()),
                        ),
                        const SizedBox(width: 12),
                        _QuickActionCard(
                          icon: Icons.document_scanner_rounded,
                          label: 'Fiş\nOkuma',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: () => Get.to(() => const ReceiptPage()),
                        ),
                        const SizedBox(width: 12),
                        _QuickActionCard(
                          icon: Icons.edit_note_rounded,
                          label: 'Manuel\nEkleme',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: () => Get.to(() => const ManualEntryPage()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Summary Cards ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Özet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                label: 'Toplam Borç',
                                amount: fmt.format(ctrl.totalDebt.value),
                                icon: Icons.trending_down_rounded,
                                color: AppColors.debt,
                                bgColor: const Color(0xFFFEF2F2),
                                onTap: () => Get.to(() => const DebtPage()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                label: 'Toplam Alacak',
                                amount: fmt.format(ctrl.totalReceivable.value),
                                icon: Icons.trending_up_rounded,
                                color: AppColors.credit,
                                bgColor: const Color(0xFFF0FDF4),
                                onTap: () => Get.to(() => const ReceivablePage()),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Detaylar',
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_ios_rounded, color: color, size: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
