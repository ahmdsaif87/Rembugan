import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import 'social_components.dart';

class SavedView extends StatelessWidget {
  const SavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return SocialScaffold(
      title: 'Tersimpan',
      subtitle: 'Postingan dan proyek yang Anda tandai',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SocialPostCard(
            name: 'Cameron Williamson',
            handle: '@cameron - proyek',
            avatarUrl: 'https://i.pravatar.cc/100?img=33',
            body:
                'Mencari Flutter developer untuk memperhalus chat experience dan notification flow.',
            onTap: () => Get.toNamed(Routes.COMMENTS),
          ),
          const SizedBox(height: 12),
          SocialPostCard(
            name: 'Raka Pratama',
            handle: '@raka - desain',
            avatarUrl: 'https://i.pravatar.cc/100?img=47',
            body:
                'Checklist design review: hierarchy, tap target, empty state, loading state, dan copy yang jelas.',
            onTap: () => Get.toNamed(Routes.COMMENTS),
          ),
        ],
      ),
    );
  }
}
