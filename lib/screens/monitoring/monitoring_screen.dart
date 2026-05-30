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
    {
      'title': 'Motorik',
      'icon': Icons.directions_run_rounded,
      'color': AppColors.primary,
      'route': '/motorik',
      'desc': 'Kasar & Halus'
    },
    {
      'title': 'Kognitif',
      'icon': Icons.psychology_rounded,
      'color': AppColors.catKognitif,
      'route': '/kognitif',
      'desc': 'Daya pikir'
    },
    {
      'title': 'Bahasa',
      'icon': Icons.record_voice_over_rounded,
      'color': AppColors.catBahasa,
      'route': '/bahasa',
      'desc': 'Komunikasi'
    },
    {
      'title': 'Sosial &\nEmosional',
      'icon': Icons.people_rounded,
      'color': AppColors.catEmosional,
      'route': '/emosional',
      'desc': 'Interaksi sosial'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadChild();
  }

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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Sage pastel card with radius 24)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yuk, pantau\nperkembangan si kecil! 📊',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                if (_child != null) ...[
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textDark.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            _child!.gender == 'Perempuan'
                                ? 'assets/images/girl_avatar.png'
                                : 'assets/images/boy_avatar.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _child!.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Usia: ${_child!.ageInMonths} bulan',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Tambahkan data anak terlebih dahulu',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_child == null) ...[
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.child_care_rounded, size: 60, color: AppColors.textMuted.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('Belum ada data anak', style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/child_profile');
                      _loadChild();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('Tambah Anak', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Pilih Aspek Perkembangan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _categories.length,
              itemBuilder: (_, i) => _buildCategoryCard(_categories[i]),
            ),
            const SizedBox(height: 24),

            // Info box (White card with subtle shadow and Sage/Forest Green border/theme)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textDark.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tentang Milestone',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Setiap anak berkembang dengan kecepatan yang berbeda. Milestone ini merupakan panduan umum, bukan diagnosis. Konsultasikan dengan dokter jika ada kekhawatiran.',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    final color = cat['color'] as Color;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, cat['route'] as String, arguments: _child),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cat['icon'] as IconData, color: AppColors.primary, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat['title'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cat['desc'] as String,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
