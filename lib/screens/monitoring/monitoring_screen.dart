import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/child_profile.dart';

class MonitoringScreen extends StatefulWidget {
  final int? selectedChildId;
  final ValueChanged<int?>? onChildChanged;

  const MonitoringScreen({
    super.key,
    this.selectedChildId,
    this.onChildChanged,
  });

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final _db = DatabaseHelper();
  List<ChildProfile> _children = [];
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
    _loadData();
  }

  @override
  void didUpdateWidget(covariant MonitoringScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedChildId != oldWidget.selectedChildId && widget.selectedChildId != _child?.id) {
      setState(() => _loading = true);
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      _children = await _db.getChildren(userId);
      final selectedChildId = widget.selectedChildId ?? prefs.getInt('selected_child_id');
      if (_children.isNotEmpty) {
        if (selectedChildId != null) {
          _child = _children.firstWhere(
            (c) => c.id == selectedChildId,
            orElse: () => _children.first,
          );
        } else {
          _child = _children.first;
        }
        if (_child?.id != null) {
          await prefs.setInt('selected_child_id', _child!.id!);
          if (_child!.id != widget.selectedChildId) {
            widget.onChildChanged?.call(_child!.id);
          }
        }
      } else {
        _child = null;
        if (widget.selectedChildId != null) {
          widget.onChildChanged?.call(null);
        }
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _switchChild(ChildProfile child) async {
    if (_child?.id == child.id) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_child_id', child.id!);
    setState(() {
      _child = child;
    });
    widget.onChildChanged?.call(child.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
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
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.bgWhite,
                          child: Icon(
                            _child!.gender == 'Perempuan'
                                ? Icons.girl_rounded
                                : Icons.boy_rounded,
                            size: 26,
                            color: _child!.gender == 'Perempuan'
                                ? const Color(0xFFEC407A)
                                : const Color(0xFF42A5F5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _child!.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                      ),
                      // Child switcher dropdown if more than 1 child
                      if (_children.length > 1)
                        _buildChildDropdown(),
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
                      setState(() => _loading = true);
                      _loadData();
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
                childAspectRatio: 1.05,
              ),
              itemCount: _categories.length,
              itemBuilder: (_, i) => _buildCategoryCard(_categories[i]),
            ),
            const SizedBox(height: 24),

            // Info box
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

  /// Dropdown button to switch between children in monitoring
  Widget _buildChildDropdown() {
    return PopupMenuButton<ChildProfile>(
      onSelected: _switchChild,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              'Ganti',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (_) => _children.map((child) {
        final isBoy = child.gender == 'Laki-laki';
        final isSelected = _child?.id == child.id;
        return PopupMenuItem<ChildProfile>(
          value: child,
          child: Row(
            children: [
              Icon(
                isBoy ? Icons.boy_rounded : Icons.girl_rounded,
                size: 22,
                color: isBoy ? const Color(0xFF42A5F5) : const Color(0xFFEC407A),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  child.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textDark,
                  ),
                ),
              ),
              Text(
                '${child.ageInMonths} bln',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
              ],
            ],
          ),
        );
      }).toList(),
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
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cat['title'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
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
            ),
          ],
        ),
      ),
    );
  }
}
