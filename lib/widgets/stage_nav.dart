import 'package:flutter/material.dart';

import '../models/stage.dart';
import '../theme/app_colors.dart';

/// ステージ（大カテゴリ）を左右矢印つきの横スクロールチップで切り替えるナビゲーション。
class StageNav extends StatelessWidget {
  final String activeStage;
  final ValueChanged<String> onChanged;

  const StageNav({super.key, required this.activeStage, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final index = kStages.indexWhere((s) => s.key == activeStage);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: AppColors.moss,
            onPressed: index > 0 ? () => onChanged(kStages[index - 1].key) : null,
            disabledColor: AppColors.moss.withValues(alpha: 0.25),
          ),
          Expanded(
            child: SizedBox(
              height: 58,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kStages.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final stage = kStages[i];
                  final active = stage.key == activeStage;
                  return _StageChip(
                    label: stage.label,
                    range: stage.range,
                    active: active,
                    onTap: () => onChanged(stage.key),
                  );
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: AppColors.moss,
            onPressed: index < kStages.length - 1
                ? () => onChanged(kStages[index + 1].key)
                : null,
            disabledColor: AppColors.moss.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  final String label;
  final String range;
  final bool active;
  final VoidCallback onTap;

  const _StageChip({
    required this.label,
    required this.range,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = active ? Colors.white : AppColors.ink;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 108),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.moss : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? AppColors.moss : AppColors.moss.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 2),
            Text(
              range,
              style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
