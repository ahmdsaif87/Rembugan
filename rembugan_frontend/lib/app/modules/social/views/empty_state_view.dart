import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_chrome.dart';
import 'social_components.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SocialScaffold(
      title: 'Empty State',
      subtitle: 'Pattern reusable untuk data kosong',
      child: AppEmptyState(
        icon: FluentIcons.box_24_regular,
        title: 'Belum ada konten',
        message:
            'Saat data tersedia, konten akan tampil di sini dengan layout yang mudah dipindai.',
      ),
    );
  }
}
