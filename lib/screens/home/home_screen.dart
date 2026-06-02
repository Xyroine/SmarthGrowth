import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/child_profile.dart';
import '../../models/user.dart';

class HomeScreen extends StatefulWidget {
  final int? selectedChildId;
  final ValueChanged<int?>? onChildChanged;

  const HomeScreen({
    super.key,
    this.selectedChildId,
    this.onChildChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper();
  AppUser? _user;
  List<ChildProfile> _children = [];
  ChildProfile? _child;
  Map<String, double> _progress = {};
  bool _loading = true;

  // Animation for child switch
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final _tips = [
    {'title': 'Ajak Bicara Si Kecil', 'desc': 'Berbicaralah sesering mungkin dengan anak, ini merangsang perkembangan bahasa mereka.', 'icon': Icons.record_voice_over_rounded},
    {'title': 'Waktu Bermain', 'desc': 'Luangkan 15-30 menit bermain bersama anak setiap hari untuk mempererat bonding.', 'icon': Icons.toys_rounded},
    {'title': 'Tummy Time', 'desc': 'Letakkan bayi tengkurap 3-5 menit beberapa kali sehari untuk melatih otot leher.', 'icon': Icons.child_care_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.value = 1.0;
    _loadData();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedChildId != oldWidget.selectedChildId && widget.selectedChildId != _child?.id) {
      setState(() => _loading = true);
      _loadData();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) { if (mounted) setState(() => _loading = false); return; }
      _user = await _db.getUserById(userId);
      _children = await _db.getChildren(userId);
      if (_children.isNotEmpty) {
        final selectedChildId = widget.selectedChildId ?? prefs.getInt('selected_child_id');
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
          // Sync with parent navigation
          if (_child!.id != widget.selectedChildId) {
            widget.onChildChanged?.call(_child!.id);
          }
          _progress = await _db.getCategoryProgress(_child!.id!, _child!.ageInMonths);
        }
      } else {
        _child = null;
        _progress = {};
        if (widget.selectedChildId != null) {
          widget.onChildChanged?.call(null);
        }
      }
    } catch (e) {
      debugPrint('HomeScreen DB error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _selectChild(ChildProfile child) async {
    if (_child?.id == child.id) return;
    // Fade out → switch → fade in
    await _fadeCtrl.reverse();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_child_id', child.id!);
    _child = child;
    widget.onChildChanged?.call(child.id);
    _progress = await _db.getCategoryProgress(child.id!, child.ageInMonths);
    if (mounted) setState(() {});
    await _fadeCtrl.forward();
  }

  Future<void> _deleteChild(ChildProfile child) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Data Anak?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textDark),
        ),
        content: Text(
          'Data "${child.name}" beserta semua riwayat milestone dan pertumbuhan akan dihapus secara permanen.',
          style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.nunito(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: GoogleFonts.nunito(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deleteChild(child.id!);
      final prefs = await SharedPreferences.getInstance();
      // If we deleted the selected child, clear selection
      if (prefs.getInt('selected_child_id') == child.id) {
        await prefs.remove('selected_child_id');
        widget.onChildChanged?.call(null);
      } else {
        // Just trigger rebuild
        widget.onChildChanged?.call(prefs.getInt('selected_child_id'));
      }
      setState(() => _loading = true);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async { setState(() => _loading = true); await _loadData(); },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Child switcher (always show if there are children)
                      if (_children.isNotEmpty) ...[
                        _buildChildSwitcher(),
                        const SizedBox(height: 20),
                      ],

                      // Child profile card with fade transition
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_child != null) _buildChildCard()
                            else _buildAddChildCard(),
                            const SizedBox(height: 24),

                            // Progress section
                            if (_child != null) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Progress terkini ${_child!.name.split(' ').first}',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'Detail ',
                                    style: GoogleFonts.nunito(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildProgressCard(),
                              const SizedBox(height: 24),

                              // Daily Tips
                              Text(
                                'Tips Harian 💡',
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                              ),
                              const SizedBox(height: 16),
                              ..._tips.map((tip) => _buildTipCard(tip)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Horizontal child switcher with avatars + "Add" button
  Widget _buildChildSwitcher() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anak Saya',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _children.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == _children.length) {
                return _buildAddChildChip();
              }
              return _buildChildChip(_children[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChildChip(ChildProfile child) {
    final isSelected = _child?.id == child.id;
    final isBoy = child.gender == 'Laki-laki';
    final avatarColor = isBoy ? const Color(0xFF42A5F5) : const Color(0xFFEC407A);

    return GestureDetector(
      onTap: () => _selectChild(child),
      onLongPress: () => _deleteChild(child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? avatarColor.withValues(alpha: 0.15) : AppColors.bgWhite,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Icon(
                isBoy ? Icons.boy_rounded : Icons.girl_rounded,
                size: 28,
                color: isSelected ? avatarColor : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              child.name.split(' ').first,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.textDark : AppColors.textMuted,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddChildChip() {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, '/child_profile');
        setState(() => _loading = true);
        _loadData();
      },
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.add_rounded, size: 24, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            Text(
              'Tambah',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      width: double.infinity,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.bgCream,
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Image.asset('assets/images/logoo_1.png', width: 37, height: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Halo, ${_user?.name ?? 'Ibundaa'}!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard() {
    final isBoy = _child!.gender == 'Laki-laki';
    final giziStatus = _child!.nutritionStatus;
    final giziColor = _getGiziColor(giziStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.bgWhite,
                  child: Icon(
                    isBoy ? Icons.boy_rounded : Icons.girl_rounded,
                    size: 40,
                    color: isBoy ? const Color(0xFF42A5F5) : const Color(0xFFEC407A),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _child!.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _child!.shortAgeString,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(width: 4, height: 4,
                          decoration: BoxDecoration(color: AppColors.textDark.withValues(alpha: 0.4), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(
                          _child!.gender,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Glassmorphic data bar (BB/TB/Gizi)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _infoItem('BB', '${_child!.weight?.toStringAsFixed(1) ?? '-'} Kg'),
                    Container(width: 1, height: 30, color: AppColors.divider.withValues(alpha: 0.3)),
                    _infoItem('TB', '${_child!.height?.toStringAsFixed(1) ?? '-'} cm'),
                    Container(width: 1, height: 30, color: AppColors.divider.withValues(alpha: 0.3)),
                    _giziBadge(giziStatus, giziColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGiziColor(String status) {
    switch (status) {
      case 'Gizi Baik':
        return const Color(0xFF2D6A4F);
      case 'Gizi Kurang':
        return const Color(0xFFE65100);
      case 'Gizi Lebih':
        return const Color(0xFFD84315);
      default:
        return AppColors.textMuted;
    }
  }

  Color _getGiziBgColor(String status) {
    switch (status) {
      case 'Gizi Baik':
        return const Color(0xFFE8F5E9);
      case 'Gizi Kurang':
        return const Color(0xFFFFF3E0);
      case 'Gizi Lebih':
        return const Color(0xFFFFEBEE);
      default:
        return AppColors.secondary;
    }
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      ],
    );
  }

  Widget _giziBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getGiziBgColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAddChildCard() {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, '/child_profile');
        setState(() => _loading = true);
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
          boxShadow: [BoxShadow(color: AppColors.textDark.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
            child: const Icon(Icons.add_rounded, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('Tambahkan Data Anak', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 8),
          Text('Mulai pantau tumbuh kembang si kecil', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
        ]),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProgressRow('Motorik', _progress['motorik'] ?? 0, AppColors.primary),
          const SizedBox(height: 16),
          _buildProgressRow('Kognitif', _progress['kognitif'] ?? 0, AppColors.catKognitif),
          const SizedBox(height: 16),
          _buildProgressRow('Bahasa', _progress['bahasa'] ?? 0, AppColors.catBahasa),
          const SizedBox(height: 16),
          _buildProgressRow('Sosial & Emosional', _progress['sosial_emosional'] ?? 0, AppColors.catEmosional),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark))),
            Text('${percentage.toInt()}%', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (percentage / 100.0).clamp(0.0, 1.0),
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20))),
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.textDark.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(14)),
          child: Icon(tip['icon'] as IconData, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tip['title'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(tip['desc'] as String, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}
