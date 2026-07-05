import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// stage/month のフィルタや選択に共通で使う丸ピル型チップ。
class PillChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color activeColor;
  final Color idleBorderColor;
  final Color idleBackground;
  final Color idleTextColor;

  const PillChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    required this.activeColor,
    required this.idleBorderColor,
    this.idleBackground = Colors.white,
    this.idleTextColor = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: active ? activeColor : idleBackground,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? activeColor : idleBorderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : idleTextColor,
          ),
        ),
      ),
    );
  }
}
