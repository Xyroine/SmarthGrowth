import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/article.dart';
import '../../widgets/article_card.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});
  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final _db = DatabaseHelper();
  List<Article> _articles = [];
  String _selectedCategory = 'Semua';
  bool _loading = true;
  final _categories = ['Semua', 'Kesehatan', 'Tumbuh Kembang', 'Parenting', 'Psikologi Anak'];

  @override
  void initState() { super.initState(); _loadArticles(); }

  Future<void> _loadArticles() async {
    _articles = await _db.getArticles(category: _selectedCategory);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Edukasi 📚', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        const SizedBox(height: 4),
        Text('Artikel seputar tumbuh kembang anak', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textMuted)),
        const SizedBox(height: 18),

        // Category chips
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final selected = cat == _selectedCategory;
              return GestureDetector(
                onTap: () { setState(() { _selectedCategory = cat; _loading = true; }); _loadArticles(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? AppColors.primaryDark : AppColors.divider.withValues(alpha: 0.4)),
                    boxShadow: selected ? [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))] : null,
                  ),
                  child: Text(cat, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.textMuted)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: CircularProgressIndicator(color: AppColors.primary)))
        else if (_articles.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(children: [
              Icon(Icons.article_outlined, size: 48, color: AppColors.textMuted.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text('Belum ada artikel', style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textMuted)),
            ]),
          ))
        else
          ..._articles.map((a) => ArticleCard(
            title: a.title, category: a.category,
            onTap: () => Navigator.pushNamed(context, '/article_detail', arguments: a),
          )),
      ]),
    );
  }
}
