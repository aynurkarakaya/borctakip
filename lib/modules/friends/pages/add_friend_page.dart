// lib/modules/friends/pages/add_friend_page.dart
// VERİTABANI BAĞLANTISI KOPARILDI — Tüm veriler sanal (mock) datadır.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';

// ─────────────────────────────────────────────
// MOCK / SANAL VERİ — Firestore bağlantısı yok
// ─────────────────────────────────────────────
final _mockUsers = <UserModel>[
  UserModel(
    uid: 'mock_001',
    name: 'Ahmet Yılmaz',
    username: 'ahmetyilmaz',
    email: 'ahmet@ornek.com',
    phone: '0532 111 2233',
    accountType: 'user',
    createdAt: DateTime(2024, 1, 10),
  ),
  UserModel(
    uid: 'mock_002',
    name: 'Elif Demir',
    username: 'elifdemir',
    email: 'elif@ornek.com',
    phone: '0541 222 3344',
    accountType: 'user',
    createdAt: DateTime(2024, 2, 5),
  ),
  UserModel(
    uid: 'mock_003',
    name: 'Murat Kaya',
    username: 'muratkaya',
    email: 'murat@ornek.com',
    phone: '0555 333 4455',
    accountType: 'user',
    createdAt: DateTime(2024, 3, 20),
  ),
  UserModel(
    uid: 'mock_004',
    name: 'Zeynep Arslan',
    username: 'zeyneparslan',
    email: 'zeynep@ornek.com',
    phone: '0530 444 5566',
    accountType: 'user',
    createdAt: DateTime(2024, 4, 15),
  ),
  UserModel(
    uid: 'mock_005',
    name: 'Burak Çelik',
    username: 'burakcelik',
    email: 'burak@ornek.com',
    phone: '0544 555 6677',
    accountType: 'user',
    createdAt: DateTime(2024, 5, 1),
  ),
  UserModel(
    uid: 'mock_006',
    name: 'Selin Öztürk',
    username: 'selinozturk',
    email: 'selin@ornek.com',
    phone: '0506 666 7788',
    accountType: 'user',
    createdAt: DateTime(2024, 6, 8),
  ),
  UserModel(
    uid: 'mock_007',
    name: 'Emre Şahin',
    username: 'emresahin',
    email: 'emre@ornek.com',
    phone: '0533 777 8899',
    accountType: 'user',
    createdAt: DateTime(2024, 7, 22),
  ),
  UserModel(
    uid: 'mock_008',
    name: 'Ayşe Kılıç',
    username: 'aysekilic',
    email: 'ayse@ornek.com',
    phone: '0542 888 9900',
    accountType: 'user',
    createdAt: DateTime(2024, 8, 18),
  ),
];

// Mock arkadaş UID listesi (zaten arkadaş olanlar)
final _mockFriendIds = <String>{'mock_003'};

// Mock gönderilmiş istek UID listesi
final _mockRequestedIds = <String>{};

// ─────────────────────────────────────────────

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final _searchCtrl = TextEditingController();

  List<UserModel> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  final Set<String> _requestedIds = Set.from(_mockRequestedIds);
  final Set<String> _friendIds = Set.from(_mockFriendIds);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Sanal arama — gerçek ağ isteği yok.
  Future<void> _search() async {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      _showSnack('Uyarı', 'Kullanıcı adı girin');
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = false;
      _results = [];
    });

    // Gerçekmiş gibi kısa bir gecikme
    await Future.delayed(const Duration(milliseconds: 500));

    final results = _mockUsers
        .where((u) =>
            u.username.toLowerCase().contains(query) ||
            u.name.toLowerCase().contains(query))
        .toList();

    if (!mounted) return;
    setState(() {
      _results = results;
      _hasSearched = true;
      _isSearching = false;
    });
  }

  /// Sanal istek gönder — Firestore'a yazmaz.
  void _sendRequest(UserModel user) {
    setState(() => _requestedIds.add(user.uid));
    _showSnack(
      'Gönderildi ✓',
      '${user.name} kullanıcısına arkadaşlık isteği gönderildi.',
      isSuccess: true,
    );
  }

  void _showSnack(
    String title,
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isError
            ? AppColors.error
            : isSuccess
                ? AppColors.success
                : null,
        colorText: isError || isSuccess ? Colors.white : null,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Arkadaş Ekle',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            const Divider(height: 1, color: AppColors.border),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: const InputDecoration(
                  hintText: 'Kullanıcı adı ile ara...',
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSearching ? null : _search,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Ara',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (!_hasSearched) {
      return const _EmptyState(
        icon: Icons.person_search_rounded,
        title: 'Arkadaş Ara',
        message: 'Kullanıcı adını yaz ve Ara butonuna bas.',
      );
    }

    if (_results.isEmpty) {
      return _EmptyState(
        icon: Icons.person_off_rounded,
        title: 'Kullanıcı Bulunamadı',
        message: '"${_searchCtrl.text.trim()}" için eşleşen kullanıcı yok.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final user = _results[i];
        return _UserTile(
          user: user,
          isRequested: _requestedIds.contains(user.uid),
          isFriend: _friendIds.contains(user.uid),
          onSend: () => _sendRequest(user),
        );
      },
    );
  }
}

// ────────── Yardımcı widget'lar (değişmedi) ──────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final bool isRequested;
  final bool isFriend;
  final VoidCallback onSend;

  const _UserTile({
    required this.user,
    required this.isRequested,
    required this.isFriend,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 390;
          final userInfo = Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final action = _buildAction();

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                userInfo,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: userInfo),
              const SizedBox(width: 12),
              Flexible(
                fit: FlexFit.loose,
                child: Align(alignment: Alignment.centerRight, child: action),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAction() {
    if (isFriend) {
      return _chip('Arkadaşsınız', AppColors.success, Icons.check_rounded);
    }
    if (isRequested) {
      return _chip(
        'İstek Gönderildi',
        AppColors.warning,
        Icons.hourglass_bottom_rounded,
      );
    }
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: onSend,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'İstek Gönder',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
