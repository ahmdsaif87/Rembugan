import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:async';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/preview_page.dart';

import '../controllers/room_chat_controller.dart';

class RoomChatView extends StatefulWidget {
  const RoomChatView({super.key});
  @override
  State<RoomChatView> createState() => _RoomChatViewState();
}

class _RoomChatViewState extends State<RoomChatView> {
  late final RoomChatController ctrl;
  final _scrollCtrl = ScrollController();
  final _userScrolledUp = false.obs;
  StreamSubscription? _msgSub;
  StreamSubscription? _loadingSub;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(RoomChatController());
    _msgSub = ctrl.messages.listen((_) {
      if (_scrollCtrl.hasClients) {
        final isNearBottom = _scrollCtrl.position.maxScrollExtent - _scrollCtrl.position.pixels < 50;
        if (isNearBottom) _afterFrame(_scrollToBottom);
      }
    });
    _loadingSub = ctrl.isLoading.listen((loading) {
      if (!loading) _afterFrame(_scrollToBottom);
    });
    _scrollCtrl.addListener(_onScrollChanged);
  }

  double? _lastExtent;
  double? _lastPixels;

  void _onScrollChanged() {
    if (!_scrollCtrl.hasClients) return;
    final pixels = _scrollCtrl.position.pixels;
    final extent = _scrollCtrl.position.maxScrollExtent;

    if (_lastExtent != null && extent > _lastExtent!) {
      final wasNearBottom = (_lastExtent! - _lastPixels!) < 50;
      if (wasNearBottom) _afterFrame(_scrollToBottom);
    }

    _userScrolledUp.value = extent - pixels > 50;
    _lastExtent = extent;
    _lastPixels = pixels;
  }

  void _afterFrame(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) => fn());
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _loadingSub?.cancel();
    _scrollCtrl.removeListener(_onScrollChanged);
    _scrollCtrl.dispose();
    Get.delete<RoomChatController>();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: _buildAppBar(c),
      body: AppLayeredBackground(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Obx(() {
                    if (ctrl.isLoading.value) {
                      return const _ChatShimmer();
                    }
                    final msgs = ctrl.messages;
                    if (msgs.isEmpty) return const SizedBox.shrink();
                    return ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _itemCount(msgs),
                      itemBuilder: (context, index) => _buildChatItem(c, index, msgs),
                    );
                  }),
                  Obx(() {
                    if (!_userScrolledUp.value) return const SizedBox.shrink();
                    return Positioned(
                      right: 16,
                      bottom: 16,
                      child: Material(
                        color: AppColors.transparent,
                        child: InkWell(
                          onTap: () {
                            _userScrolledUp.value = false;
                            _scrollToBottom();
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              FluentIcons.chevron_down_24_regular,
                              color: c.textPrimary,
                              size: 24,
                            ),
                        ),
                      ),
                    ),
                    );
                  }),
                ],
              ),
            ),
            _buildInputBar(c),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppC c) {
    final room = ctrl.room;
    return AppBar(
      backgroundColor: c.surface.withValues(alpha: 0.96),
      elevation: 0,
      surfaceTintColor: AppColors.transparent,
      leading: Tooltip(
        message: 'Kembali',
        child: IconButton(
          icon: Icon(FluentIcons.chevron_left_24_regular, color: c.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      title: Row(
        children: [
          Obx(() => Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: c.primarySoft,
                backgroundImage: room.photoUrl != null
                    ? NetworkImage(room.photoUrl!) as ImageProvider
                    : null,
                child: room.photoUrl == null
                    ? Text(room.name.isNotEmpty ? room.name[0].toUpperCase() : '?')
                    : null,
              ),
              if (room.type == 'dm')
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: ctrl.otherUserOnline.value ? AppColors.success : AppColors.textSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.surface, width: 2),
                    ),
                  ),
                ),
            ],
          )),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: AppFonts.satoshiStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: c.textPrimary,
                  ),
                ),
                if (room.type == 'dm')
                  Obx(() => Text(
                    ctrl.otherUserOnline.value ? 'Online' : 'Offline',
                    style: AppFonts.satoshiStyle(
                      fontSize: 12, color: ctrl.otherUserOnline.value ? AppColors.success : c.textSecondary,
                    ),
                  )),
              ],
            ),
          ),
        ],
      ),
      actions: const [],
    );
  }

  bool _isSameDay(String a, String b) {
    try {
      final da = DateTime.parse(a).toLocal();
      final db = DateTime.parse(b).toLocal();
      return da.year == db.year && da.month == db.month && da.day == db.day;
    } catch (_) {
      return true;
    }
  }

  bool _isConsecutive(ChatMessage a, ChatMessage b) {
    if (a.isMe != b.isMe) return false;
    if (a.isMe) {
      try {
        final ta = DateTime.parse(a.time);
        final tb = DateTime.parse(b.time);
        return tb.difference(ta).inMinutes < 5;
      } catch (_) {
        return false;
      }
    } else {
      if (a.senderName != b.senderName) return false;
      try {
        final ta = DateTime.parse(a.time);
        final tb = DateTime.parse(b.time);
        return tb.difference(ta).inMinutes < 5;
      } catch (_) {
        return false;
      }
    }
  }

  int _itemCount(List<ChatMessage> msgs) {
    if (msgs.isEmpty) return 0;
    int seps = 1;
    for (int i = 1; i < msgs.length; i++) {
      if (!_isSameDay(msgs[i - 1].time, msgs[i].time)) seps++;
    }
    return msgs.length + seps;
  }

  Widget _buildChatItem(AppC c, int target, List<ChatMessage> msgs) {
    int current = 0;
    String? prevDate;
    for (int i = 0; i < msgs.length; i++) {
      final msg = msgs[i];
      final msgDate = _dateKey(msg.time);
      final needsSep = msgDate != prevDate;
      if (needsSep) {
        if (current == target) {
          return _dateSeparator(c: c, date: msg.time);
        }
        current++;
        prevDate = msgDate;
      }
      if (current == target) {
        final isFirst = i == 0 || !_isConsecutive(msgs[i - 1], msg);
        final isLast = i == msgs.length - 1 || !_isConsecutive(msg, msgs[i + 1]);
        return _buildMessageBubble(c: c, msg: msg, isFirstInGroup: isFirst, isLastInGroup: isLast);
      }
      current++;
    }
    return const SizedBox.shrink();
  }

  String? _dateKey(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${dt.month}-${dt.day}';
    } catch (_) {
      return null;
    }
  }

  Widget _dateSeparator({required AppC c, required String date}) {
    final sep = dateSeparator(date);
    if (sep.isEmpty) return const SizedBox.shrink();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border.withValues(alpha: 0.6)),
          ),
          child: Text(
            sep,
            style: AppFonts.satoshiStyle(
              fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _isPdfUrl(ChatMessage msg) {
    final name = msg.attachmentName?.toLowerCase() ?? '';
    final url = msg.attachmentUrl?.toLowerCase() ?? '';
    return name.endsWith('.pdf') || url.contains('.pdf');
  }

  Widget _buildFileCard(AppC c, ChatMessage msg) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: msg.isMe ? c.surface.withValues(alpha: 0.12) : c.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(
          color: msg.isMe ? c.surface.withValues(alpha: 0.2) : c.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            (msg.attachmentName?.endsWith('.png') == true ||
                    msg.attachmentName?.endsWith('.jpg') == true)
                ? FluentIcons.image_24_regular
                : FluentIcons.document_24_regular,
            color: msg.isMe ? AppColors.white : AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.attachmentName ?? 'File',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: msg.isMe ? AppColors.white : c.textPrimary,
                  ),
                ),
                if (msg.attachmentSize != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    formatBytes(msg.attachmentSize),
                    style: AppFonts.satoshiStyle(
                      fontSize: 10,
                      color: msg.isMe
                          ? AppColors.white.withValues(alpha: 0.7)
                          : c.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            FluentIcons.arrow_download_24_regular,
            color: msg.isMe ? AppColors.white70 : c.textSecondary,
            size: 18,
          ),
        ],
      ),
    );
  }

  BorderRadius _bubbleRadius(bool isMe, bool first, bool last) {
    if (isMe) {
      if (first && last) {
        return const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      } else if (first) {
        return const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(4),
        );
      } else if (last) {
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      } else {
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(4),
        );
      }
    } else {
      if (first && last) {
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      } else if (first) {
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        );
      } else if (last) {
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      } else {
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        );
      }
    }
  }

  Widget _buildMessageBubble({
    required AppC c,
    required ChatMessage msg,
    bool isFirstInGroup = true,
    bool isLastInGroup = true,
  }) {
    final room = ctrl.room;
    final isGroup = room.type == 'group';
    final senderName = !msg.isMe && isGroup && isFirstInGroup ? msg.senderName : null;
    final topPad = isFirstInGroup ? 4.0 : 1.0;
    final bottomPad = isLastInGroup ? 4.0 : 1.0;
    return Padding(
      padding: EdgeInsets.only(top: topPad, bottom: bottomPad),
      child: Row(
        mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe && isFirstInGroup && isGroup)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: c.grey100,
                backgroundImage: msg.senderPhotoUrl != null
                    ? NetworkImage(msg.senderPhotoUrl!) as ImageProvider
                    : null,
                child: msg.senderPhotoUrl == null
                    ? Text(msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : '?')
                    : null,
              ),
            ),
          IntrinsicWidth(
            child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: msg.isMe ? AppColors.primary500 : c.surface,
                border: msg.isMe ? null : Border.all(color: c.border),
                borderRadius: _bubbleRadius(msg.isMe, isFirstInGroup, isLastInGroup),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (senderName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        senderName,
                        style: AppFonts.satoshiStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  if (msg.text.isNotEmpty && msg.type != 'file')
                    Text(
                      msg.text,
                      style: AppFonts.satoshiStyle(
                        fontSize: 14, color: msg.isMe ? AppColors.white : c.textPrimary, height: 1.4,
                      ),
                    ),
                  if (msg.attachmentUrl != null) ...[
                    if (msg.text.isNotEmpty || msg.type == 'file') const SizedBox(height: 8),
                    if (isImageUrl(msg.attachmentUrl!))
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ImagePreviewPage(url: msg.attachmentUrl!, filename: msg.attachmentName),
                        )),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            msg.attachmentUrl!,
                            width: 220,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                width: 220, height: 160,
                                color: c.surfaceSecondary,
                              );
                            },
                            errorBuilder: (_, __, ___) => _buildFileCard(c, msg),
                          ),
                        ),
                      )
                    else if (_isPdfUrl(msg))
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PdfPreviewPage(url: msg.attachmentUrl!, filename: msg.attachmentName),
                        )),
                        child: _buildFileCard(c, msg),
                      )
                    else
                      GestureDetector(
                        onTap: () async {
                          try {
                            await openFile(msg.attachmentUrl!, msg.attachmentName);
                          } catch (_) {
                            if (context.mounted) Get.snackbar('Gagal', 'Gagal membuka file');
                          }
                        },
                        child: _buildFileCard(c, msg),
                      ),
                  ],
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      formatTimeOnly(msg.time),
                      style: AppFonts.satoshiStyle(
                        fontSize: 10,
                        color: msg.isMe
                            ? AppColors.white.withValues(alpha: 0.7)
                            : c.textTertiary,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (msg.isMe && isGroup) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildInputBar(AppC c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          if (!ctrl.isUploading.value) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            color: c.grey50,
            child: Row(
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 12),
                Text('Mengupload...', style: AppFonts.satoshiStyle(fontSize: 13, color: c.textSecondary)),
              ],
            ),
          );
        }),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(color: c.surface),
          child: Row(
            children: [
              Material(
                color: AppColors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppRadius.lg),
                            topRight: Radius.circular(AppRadius.lg),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40, height: 4,
                              decoration: BoxDecoration(
                                color: c.border,
                                borderRadius: BorderRadius.circular(AppRadius.xxs),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Lampirkan File & Dokumen',
                              style: AppFonts.satoshiStyle(
                                fontSize: 16, fontWeight: FontWeight.w600, color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            AppListItem(
                              leading: const Icon(FluentIcons.image_24_regular, color: AppColors.primary),
                              title: 'Foto & Media',
                              onTap: () {
                                Get.back();
                                ctrl.uploadAndSendFile();
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppListItem(
                              leading: const Icon(FluentIcons.document_24_regular, color: AppColors.primary),
                              title: 'Dokumen & File PDF',
                              onTap: () {
                                Get.back();
                                ctrl.uploadAndSendFile();
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: c.surface,
                      border: Border.all(color: c.border),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(FluentIcons.add_24_regular, color: c.textSecondary, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: ctrl.messageController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: c.surface,
                    hintText: 'Ketik pesan',
                    hintStyle: AppFonts.satoshiStyle(fontSize: 14, color: c.textSecondary.withValues(alpha: 0.6)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 13.5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: c.border.withValues(alpha: 0.8), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: c.textPrimary.withValues(alpha: 0.4), width: 1.2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: c.border.withValues(alpha: 0.8), width: 1.0),
                    ),
                  ),
                  style: AppFonts.satoshiStyle(fontSize: 14, color: c.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: AppColors.transparent,
                child: InkWell(
                  onTap: () => ctrl.sendMessage(),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Center(
                      child: Icon(FluentIcons.send_24_filled, color: AppColors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatShimmer extends StatelessWidget {
  const _ChatShimmer();
  @override
  Widget build(BuildContext context) {
    return const SkeletonChatList();
  }
}
