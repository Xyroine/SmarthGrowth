import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: barColor),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(label, style: GoogleFonts.nunito(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark,
                )),
              ),
              Text('${percentage.toInt()}%', style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w700, color: barColor,
              )),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: barColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
