import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';
import '../../social/views/comment_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLayeredBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabs(),
              Expanded(
                child: Obx(() => ListView(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                  children: [
                    _PostCardWidget(
                      avatarUrl: 'https://i.pravatar.cc/100?img=33',
                      name: 'Cameron Williamson',
                      subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
                      content:
                          'Ada yang tertarik gabung tim buat ikut Creative Fest 2026? Kuota tim tinggal 1 slot lagi buat backend developer. Kita rencana pake FastAPI + PostgreSQL. Yang minat silakan cek profil atau langsung chat ya! 🚀🚀',
                      hasImage: true,
                      imageAssets: const [
                        'lib/assets/img/contoh poster1.jpeg',
                        'lib/assets/img/contoh poster2.jpeg',
                      ],
                      initialLikes: 142,
                      showFollowButton: controller.activeTab.value == 0,
                      onShowComments: () => showCommentsSheet(context),
                      onShowShare: () => _showShareSheet(context),
                    ),
                    const Divider(height: 1, color: Color(0xFFE1E4E8)),
                    _PostCardWidget(
                      avatarUrl: 'https://i.pravatar.cc/100?img=12',
                      name: 'Marvin McKinney',
                      subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
                      content:
                          'Tadi siang habis coba fitur scan resume terbaru di Rembugan, gila ternyata akurat banget ya! Skill Figma langsung ke-detect otomatis. UI-nya juga clean banget, jadi makin semangat nyari proyek kolaborasi di sini. Mantap tim developer! 👏✨',
                      hasImage: false,
                      initialLikes: 98,
                      showFollowButton: controller.activeTab.value == 0,
                      onShowComments: () => showCommentsSheet(context),
                      onShowShare: () => _showShareSheet(context),
                    ),
                    const Divider(height: 1, color: Color(0xFFE1E4E8)),
                    _PostCardWidget(
                      avatarUrl: 'https://i.pravatar.cc/100?img=12',
                      name: 'Marvin McKinney',
                      subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
                      content:
                          'Sharing sedikit tips buat temen-temen D4 Teknik Informatika yang lagi ngerjain project akhir: Coba biasain bikin design system di Figma dulu sebelum masuk ke codingan Flutter. Ini bener-bener ngehemat waktu integrasi UI nanti dan bikin komponen jadi reusable!',
                      hasImage: false,
                      initialLikes: 205,
                      showFollowButton: controller.activeTab.value == 0,
                      onShowComments: () => showCommentsSheet(context),
                      onShowShare: () => _showShareSheet(context),
                    ),
                    const Divider(height: 1, color: Color(0xFFE1E4E8)),
                    _PostCardWidget(
                      avatarUrl: 'https://i.pravatar.cc/100?img=33',
                      name: 'Cameron Williamson',
                      subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
                      content:
                          'Guys, pendaftaran Essay & Poster Competition Creative Fest 2026 udah mau ditutup tanggal 20 Juni besok. Buat yang pengen asah portofolio tingkat nasional wajib banget ikut sih. Link registrasi ada di detail lomba ya! 🎨✍️',
                      hasImage: true,
                      imageAssets: const [
                        'lib/assets/img/contoh poster1.jpeg',
                      ],
                      initialLikes: 87,
                      showFollowButton: controller.activeTab.value == 0,
                      onShowComments: () => showCommentsSheet(context),
                      onShowShare: () => _showShareSheet(context),
                    ),
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppNavDestination.home),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beranda',
                  style: AppFonts.headingStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: FluentIcons.alert_24_regular,
            badge: true,
            onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
          ),
          const SizedBox(width: 10),
          AppIconButton(
            icon: FluentIcons.chat_empty_24_regular,
            onTap: () => Get.toNamed(Routes.CHAT),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE1E4E8))),
        ),
        child: Obx(() => Row(
          children: [
            _buildTabButton('Untukmu', controller.activeTab.value == 0, 0),
            _buildTabButton('Mengikuti', controller.activeTab.value == 1, 1),
          ],
        )),
      ),
    );
  }

  Widget _buildTabButton(String label, bool active, int index) {
    return Expanded(
      child: InkWell(
        onTap: () => controller.setTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.textPrimary : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 13.5,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ShareSheet(),
    );
  }
}

class _PostCardWidget extends StatefulWidget {
  const _PostCardWidget({
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.content,
    required this.hasImage,
    this.imageUrl,
    this.imageAssets,
    this.showFollowButton = true,
    this.initialLikes = 120,
    required this.onShowComments,
    required this.onShowShare,
  });

  final String avatarUrl;
  final String name;
  final String subtitle;
  final String content;
  final bool hasImage;
  final String? imageUrl;
  final List<String>? imageAssets;
  final bool showFollowButton;
  final int initialLikes;
  final VoidCallback onShowComments;
  final VoidCallback onShowShare;

  @override
  State<_PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<_PostCardWidget> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikes;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    Get.snackbar(
      _isBookmarked ? 'Postingan disimpan' : 'Postingan dihapus',
      _isBookmarked
          ? 'Postingan berhasil disimpan ke penanda kamu.'
          : 'Postingan dihapus dari penanda kamu.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _isBookmarked ? const Color(0xFFEDFDF5) : Colors.white,
      colorText: _isBookmarked ? const Color(0xFF15803D) : AppColors.textPrimary,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: widget.onShowComments,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: const AssetImage(
                      'lib/assets/img/avatar.png',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: AppFonts.satoshiStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.satoshiStyle(
                            fontSize: 11.5,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.showFollowButton) ...[
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 31),
                        side: const BorderSide(color: Color(0xFFDADDE2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      child: Text(
                        'Ikuti',
                        style: AppFonts.satoshiStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  const Icon(
                    FluentIcons.more_vertical_24_regular,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.content,
                style: AppFonts.satoshiStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary.withValues(alpha: 0.88),
                  height: 1.56,
                ),
              ),
              if (widget.imageAssets != null && widget.imageAssets!.isNotEmpty) ...[
                const SizedBox(height: 10),
                if (widget.imageAssets!.length == 1)
                  GestureDetector(
                    onTap: () => _showImageViewer(context, assetPath: widget.imageAssets!.first),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.asset(
                        widget.imageAssets!.first,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else if (widget.imageAssets!.length == 2)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showImageViewer(context, assetPath: widget.imageAssets![0]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Image.asset(
                              widget.imageAssets![0],
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showImageViewer(context, assetPath: widget.imageAssets![1]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Image.asset(
                              widget.imageAssets![1],
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ] else if (widget.hasImage && widget.imageUrl != null) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _showImageViewer(context, imageUrl: widget.imageUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.network(
                      widget.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInteractionItem(
                    _isLiked ? FluentIcons.heart_24_filled : FluentIcons.heart_24_regular,
                    '$_likeCount',
                    'menyukai postingan',
                    _isLiked ? const Color(0xFFE5484D) : AppColors.textSecondary,
                    onTap: _toggleLike,
                  ),
                  const SizedBox(width: 22),
                  _buildInteractionItem(
                    FluentIcons.chat_24_regular,
                    '20',
                    'berkomentar',
                    AppColors.textSecondary,
                    onTap: widget.onShowComments,
                  ),
                  const Spacer(),
                  _buildInteractionItem(
                    FluentIcons.send_24_regular,
                    '',
                    'membagikan postingan',
                    AppColors.textSecondary,
                    onTap: widget.onShowShare,
                  ),
                  const SizedBox(width: 20),
                  _buildInteractionItem(
                    _isBookmarked ? FluentIcons.bookmark_24_filled : FluentIcons.bookmark_24_regular,
                    '',
                    'menyimpan postingan',
                    _isBookmarked ? const Color(0xFFD69E2E) : AppColors.textSecondary,
                    onTap: _toggleBookmark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionItem(
    IconData icon,
    String count,
    String feature,
    Color activeColor, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: activeColor.withValues(alpha: 0.88), size: 22),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                count,
                style: AppFonts.satoshiStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet();

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final List<Map<String, dynamic>> _friends = [
    {'name': 'Aisyah', 'avatar': 'lib/assets/img/avatar.png', 'sent': false},
    {'name': 'Nadia', 'avatar': 'lib/assets/img/avatar.png', 'sent': false},
    {'name': 'Raka', 'avatar': 'lib/assets/img/avatar.png', 'sent': false},
    {'name': 'Dede', 'avatar': 'lib/assets/img/avatar.png', 'sent': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Bagikan ke Teman',
            style: AppFonts.headingStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            style: AppFonts.satoshiStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Cari teman...',
              hintStyle: AppFonts.satoshiStyle(fontSize: 12, color: AppColors.textTertiary),
              prefixIcon: const Icon(FluentIcons.search_24_regular, size: 18, color: AppColors.textTertiary),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(friend['avatar']),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          friend['name'],
                          style: AppFonts.satoshiStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: friend['sent']
                            ? null
                            : () {
                                setState(() {
                                  friend['sent'] = true;
                                });
                                Get.snackbar(
                                  'Terkirim',
                                  'Postingan dibagikan ke ${friend['name']}',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFFEDFDF5),
                                  colorText: const Color(0xFF15803D),
                                  duration: const Duration(seconds: 1),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: friend['sent']
                              ? const Color(0xFFF3F4F6)
                              : AppColors.primary,
                          foregroundColor: friend['sent']
                              ? AppColors.textTertiary
                              : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          friend['sent'] ? 'Terkirim' : 'Kirim',
                          style: AppFonts.satoshiStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareAction(
                icon: FluentIcons.copy_24_regular,
                label: 'Salin Link',
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: 'https://rembugan.app/post/1'));
                  Navigator.pop(context);
                  Get.snackbar(
                    'Tautan disalin',
                    'Link postingan berhasil disalin ke clipboard.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFEDFDF5),
                    colorText: const Color(0xFF15803D),
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
              _buildShareAction(
                icon: FluentIcons.chat_24_regular,
                label: 'WhatsApp',
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar('WhatsApp', 'Membuka WhatsApp...', snackPosition: SnackPosition.BOTTOM);
                },
              ),
              _buildShareAction(
                icon: FluentIcons.send_24_regular,
                label: 'Telegram',
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar('Telegram', 'Membuka Telegram...', snackPosition: SnackPosition.BOTTOM);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppFonts.satoshiStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showImageViewer(BuildContext context, {String? assetPath, String? imageUrl}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Material(
              color: Colors.white.withValues(alpha: 0.15),
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Center(
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.95,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: assetPath != null
                      ? Image.asset(assetPath, fit: BoxFit.contain)
                      : Image.network(imageUrl!, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
