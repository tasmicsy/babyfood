import 'package:flutter/material.dart';

import '../models/stage.dart';
import '../theme/app_colors.dart';
import 'pill_chip.dart';

/// 選択中ステージの月齢（中カテゴリ）を切り替えるチップ列。「すべて」を含む。
class MonthNav extends StatelessWidget {
  final Stage stage;
  final int activeMonth;
  final ValueChanged<int> onChanged;

  const MonthNav({super.key, required this.stage, required this.activeMonth, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        itemCount: stage.months.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          if (i == 0) {
            return PillChip(
              label: 'すべて',
              active: activeMonth == kAllMonths,
              onTap: () => onChanged(kAllMonths),
              activeColor: AppColors.leaf,
              idleBorderColor: AppColors.leaf.withValues(alpha: 0.4),
              idleBackground: Colors.transparent,
              idleTextColor: AppColors.moss,
            );
          }
          final month = stage.months[i - 1];
          return PillChip(
            label: '$monthヶ月',
            active: activeMonth == month,
            onTap: () => onChanged(month),
            activeColor: AppColors.leaf,
            idleBorderColor: AppColors.leaf.withValues(alpha: 0.4),
            idleBackground: Colors.transparent,
            idleTextColor: AppColors.moss,
          );
        },
      ),
    );
  }
}
