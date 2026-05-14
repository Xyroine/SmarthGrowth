import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ArticleCard extends StatelessWidget {
  final String title;
  final String category;
  final String? imageUrl;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.title,
    required this.category,
    this.imageUrl,
    required this.onTap,
  });

  IconData _getCategoryIcon() {
    switch (category) {
      case 'Kesehatan': return Icons.favorite_rounded;
      case 'Tumbuh Kembang': return Icons.child_care_rounded;
      case 'Parenting': return Icons.family_restroom_rounded;
      case 'Psikologi Anak': return Icons.psychology_rounded;
      default: return Icons.article_rounded;
    }
  }

  Color _getCategoryColor() {
    switch (category) {
      case 'Kesehatan': return const Color(0xFFE57373);
      case 'Tumbuh Kembang': return AppColors.primary;
      case 'Parenting': return const Color(0xFF64B5F6);
      case 'Psikologi Anak': return const Color(0xFFBA68C8);
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _getCategoryColor().withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Icon(_getCategoryIcon(), size: 40, color: _getCategoryColor()),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(category, style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600, color: _getCategoryColor(),
                      )),
                    ),
                    const SizedBox(height: 8),
                    Text(title, style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark,
                    ), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('Baca selengkapnya', style: TextStyle(
                          fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
