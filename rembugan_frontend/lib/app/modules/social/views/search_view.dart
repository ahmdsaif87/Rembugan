import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();
  String _query = '';
  int _selectedChip = 0;

  static const _chips = ['Semua', 'Postingan', 'Orang', 'Proyek', 'Lomba'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
              child: Row(
                children: [
                  Tooltip(
                    message: 'Kembali',
                    child: IconButton(
                      onPressed: Get.back,
                      icon: const Icon(FluentIcons.chevron_left_24_regular),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Cari postingan, orang, proyek, lomba...',
                        hintStyle: AppFonts.satoshiStyle(
                          fontSize: 14,
                          color: c.textTertiary,
                        ),
                        filled: true,
                        fillColor: c.background,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: AppSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: BorderSide(color: c.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: BorderSide(color: c.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: const BorderSide(
                            color: AppColors.primary500,
                            width: 1.2,
                          ),
                        ),
                      ),
                      style: AppFonts.satoshiStyle(
                        fontSize: 14,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _chips.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final selected = _selectedChip == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedChip = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary500 : c.grey100,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          _chips[i],
                          style: AppFonts.satoshiStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? AppColors.white : c.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _query.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: c.primarySoft,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: const Icon(
                              FluentIcons.search_24_regular,
                              size: 28,
                              color: AppColors.primary500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Cari apa saja',
                            style: AppFonts.satoshiStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Temukan proyek, lomba, atau orang\nuntuk kolaborasi',
                            textAlign: TextAlign.center,
                            style: AppFonts.satoshiStyle(
                              fontSize: 13,
                              color: c.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Hasil pencarian untuk "$_query"',
                              style: AppFonts.satoshiStyle(
                                fontSize: 14,
                                color: c.textSecondary,
                              ),
                            ),
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
