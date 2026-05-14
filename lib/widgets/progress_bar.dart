import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomProgressBar extends StatelessWidget {
  final String label;
  final double percentage;
  final Color? color;
  final IconData? icon;

  const CustomProgressBar({
    super.key,
    required this.label,
    required this.percentage,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: barColor),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(label, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark,
                )),
              ),
              Text('${percentage.toInt()}%', style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: barColor,
              )),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: barColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
