import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/profile_service.dart';
import '../../../core/theme/theme.dart';
import 'social_components.dart';

class ProjectHistoryView extends StatelessWidget {
  const ProjectHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final userName = args?['userName'] as String? ?? '';
    final projects = (args?['projects'] as List<dynamic>?)
            ?.cast<ProjectHistoryItem>() ??
        [];
    final c = AppC.of(context);
    return SocialScaffold(
      title: 'Proyek $userName',
      subtitle: '${projects.length} proyek',
      child: projects.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Belum memiliki proyek',
                  style: AppFonts.satoshiStyle(
                    fontSize: 14,
                    color: c.textSecondary,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final project = projects[index];
                String statusLabel;
                Color statusColor;
                switch (project.status) {
                  case 'ongoing':
                    statusLabel = 'Berlangsung';
                    statusColor = AppColors.primary;
                    break;
                  case 'completed':
                    statusLabel = 'Selesai';
                    statusColor = AppColors.success500;
                    break;
                  default:
                    statusLabel = project.status;
                    statusColor = c.textSecondary;
                }

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: c.border.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.title,
                              style: AppFonts.satoshiStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Peran: ${project.role}',
                              style: AppFonts.satoshiStyle(
                                fontSize: 12,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          statusLabel,
                          style: AppFonts.satoshiStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
