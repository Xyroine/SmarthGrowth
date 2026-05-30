import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/child_profile.dart';
import '../../models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper();
  AppUser? _user;
  ChildProfile? _child;
  Map<String, double> _progress = {};
  bool _loading = true;

  final _tips = [
    {'title': 'Ajak Bicara Si Kecil', 'desc': 'Berbicaralah sesering mungkin dengan anak, ini merangsang perkembangan bahasa mereka.', 'icon': Icons.record_voice_over_rounded},
    {'title': 'Waktu Bermain', 'desc': 'Luangkan 15-30 menit bermain bersama anak setiap hari untuk mempererat bonding.', 'icon': Icons.toys_rounded},
    {'title': 'Tummy Time', 'desc': 'Letakkan bayi tengkurap 3-5 menit beberapa kali sehari untuk melatih otot leher.', 'icon': Icons.child_care_rounded},
  ];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) { if (mounted) setState(() => _loading = false); return; }
      _user = await _db.getUserById(userId);
      final children = await _db.getChildren(userId);
      if (children.isNotEmpty) {
        _child = children.first;
        _progress = await _db.getCategoryProgress(_child!.id!, _child!.ageInMonths);
      }
    } catch (e) {
      debugPrint('HomeScreen DB error (web?): $e');
    }
    if (mounted) setState(() => _loading = false);
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
                      // Child profile card
                      if (_child != null) _buildChildCard()
                      else _buildAddChildCard(),
                      const SizedBox(height: 24),

                      // Progress section
                      if (_child != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress terkini ${_child!.name.split(' ').first}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
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
          Row(
            children: [
              Image.asset('assets/images/logoo_1.png', width: 37, height: 30),
              const SizedBox(width: 12),
              Text(
                'Halo, ${_user?.name ?? 'Ibundaa'}!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
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
              // Foto profil — lingkaran sempurna + stroke putih 2px
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
                  child: ClipOval(
                    child: Image.asset('assets/images/boy_avatar.png', width: 60, height: 60, fit: BoxFit.cover),
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
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _child!.shortAgeString,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
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
                    const SizedBox(height: 4),
                    Text(
                      'Cek Terakhir : 15 hari lalu',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
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
                    const SizedBox(width: 16),
                    _infoItem('TB', '${_child!.height?.toStringAsFixed(1) ?? '-'} cm'),
                    const SizedBox(width: 16),
                    _giziBadge(_child!.nutritionStatus),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  // Badge kecil melayang untuk status gizi
  Widget _giziBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildAddChildCard() {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, '/child_profile');
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
          _buildProgressRow('Motorik', _progress['motorik'] ?? 80, AppColors.primary),
          const SizedBox(height: 16),
          _buildProgressRow('Kognitif', _progress['kognitif'] ?? 50, AppColors.catKognitif),
          const SizedBox(height: 16),
          _buildProgressRow('Bahasa', _progress['bahasa'] ?? 65, AppColors.catBahasa),
          const SizedBox(height: 16),
          _buildProgressRow('Sosial & Emosional', _progress['sosial_emosional'] ?? 95, AppColors.catEmosional),
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
            Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
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
            widthFactor: percentage / 100.0,
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
