import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/child_profile.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});
  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final _db = DatabaseHelper();
  ChildProfile? _child;
  bool _loading = true;

  final _categories = [
    {'title': 'Motorik', 'icon': Icons.directions_run_rounded, 'color': const Color(0xFF4CAF50), 'route': '/motorik', 'desc': 'Kasar & Halus'},
    {'title': 'Kognitif', 'icon': Icons.psychology_rounded, 'color': const Color(0xFF2196F3), 'route': '/kognitif', 'desc': 'Daya pikir'},
    {'title': 'Bahasa', 'icon': Icons.record_voice_over_rounded, 'color': const Color(0xFFFF9800), 'route': '/bahasa', 'desc': 'Komunikasi'},
    {'title': 'Sosial &\nEmosional', 'icon': Icons.people_rounded, 'color': const Color(0xFFE91E63), 'route': '/emosional', 'desc': 'Interaksi sosial'},
  ];

  @override
  void initState() { super.initState(); _loadChild(); }

  Future<void> _loadChild() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      final children = await _db.getChildren(userId);
      if (children.isNotEmpty) _child = children.first;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primaryDark, Color(0xFF2D8F6A)]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 5))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Yuk, pantau\nperkembangan si kecil! 📊', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.3)),
            const SizedBox(height: 10),
            Text(_child != null ? '${_child!.name} • ${_child!.shortAgeString}' : 'Tambahkan data anak terlebih dahulu',
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
            if (_child != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('Usia: ${_child!.ageInMonths} bulan', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ]),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 24),

        if (_child == null) ...[
          Center(child: Column(children: [
            const SizedBox(height: 40),
            Icon(Icons.child_care_rounded, size: 60, color: AppColors.textMuted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('Belum ada data anak', style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async { await Navigator.pushNamed(context, '/child_profile'); _loadChild(); },
              icon: const Icon(Icons.add, size: 18),
              label: Text('Tambah Anak', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ])),
        ] else ...[
          Text('Pilih Aspek Perkembangan', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.1),
            itemCount: _categories.length,
            itemBuilder: (_, i) => _buildCategoryCard(_categories[i]),
          ),
          const SizedBox(height: 24),

          // Info box
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bgWarm, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentYellow.withValues(alpha: 0.3)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline_rounded, color: AppColors.accentYellow, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tentang Milestone', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text('Setiap anak berkembang dengan kecepatan yang berbeda. Milestone ini merupakan panduan umum, bukan diagnosis. Konsultasikan dengan dokter jika ada kekhawatiran.',
                  style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textMuted, height: 1.5)),
              ])),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    final color = cat['color'] as Color;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, cat['route'] as String, arguments: _child),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(cat['icon'] as IconData, color: color, size: 26),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cat['title'] as String, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(cat['desc'] as String, style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textMuted)),
          ]),
        ]),
      ),
    );
  }
}
