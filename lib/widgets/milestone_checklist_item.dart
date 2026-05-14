import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MilestoneChecklistItem extends StatelessWidget {
  final String text;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const MilestoneChecklistItem({
    super.key,
    required this.text,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isChecked ? AppColors.primaryPale.withValues(alpha: 0.5) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isChecked ? AppColors.primary : AppColors.divider.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: isChecked ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
                  color: isChecked ? AppColors.primaryDark : AppColors.textDark,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
