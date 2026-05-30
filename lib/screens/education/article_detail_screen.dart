import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/article.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final article = ModalRoute.of(context)?.settings.arguments as Article?;
    if (article == null) return const Scaffold(body: Center(child: Text('Artikel tidak ditemukan')));

    Color catColor;
    IconData catIcon;
    switch (article.category) {
      case 'Kesehatan':
        catColor = const Color(0xFFE9967A); // Soft Salmon/Coral Accent
        catIcon = Icons.favorite_rounded;
        break;
      case 'Tumbuh Kembang':
        catColor = AppColors.primary;
        catIcon = Icons.child_care_rounded;
        break;
      case 'Parenting':
        catColor = const Color(0xFF70A1FF); // Soft blue pastel
        catIcon = Icons.family_restroom_rounded;
        break;
      case 'Psikologi Anak':
        catColor = const Color(0xFFAB47BC); // Soft purple
        catIcon = Icons.psychology_rounded;
        break;
      default:
        catColor = AppColors.textMuted;
        catIcon = Icons.article_rounded;
    }

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: catColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [catColor, catColor.withValues(alpha: 0.7)],
                  ),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Icon(catIcon, size: 50, color: Colors.white.withValues(alpha: 0.8)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        '${article.publishedAt.day}/${article.publishedAt.month}/${article.publishedAt.year}',
                        style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: AppColors.divider.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  // Article content - render paragraphs
                  ...article.content.split('\n\n').map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: p.startsWith('- ')
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: p
                                    .split('\n')
                                    .map((line) => Padding(
                                          padding: const EdgeInsets.only(bottom: 6, left: 8),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  width: 6,
                                                  height: 6,
                                                  margin: const EdgeInsets.only(top: 8, right: 10),
                                                  decoration: BoxDecoration(color: catColor, shape: BoxShape.circle)),
                                              Expanded(
                                                  child: Text(
                                                line.replaceFirst('- ', ''),
                                                style: GoogleFonts.nunito(
                                                  fontSize: 14,
                                                  color: AppColors.textDark,
                                                  height: 1.6,
                                                ),
                                              )),
                                            ],
                                          ),
                                        ))
                                    .toList())
                            : Text(
                                p,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                  height: 1.7,
                                ),
                              ),
                      )),
                  const SizedBox(height: 20),
                  // SDG info box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.eco_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SDG 3 & SDG 4',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Artikel ini mendukung tujuan SDG 3 (Kesehatan) dan SDG 4 (Pendidikan) untuk tumbuh kembang anak yang optimal.',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
