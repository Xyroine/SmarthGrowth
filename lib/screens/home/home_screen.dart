import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/child_profile.dart';
import '../../models/user.dart';
import '../../widgets/progress_bar.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return;
    _user = await _db.getUserById(userId);
    final children = await _db.getChildren(userId);
    if (children.isNotEmpty) {
      _child = children.first;
      _progress = await _db.getCategoryProgress(_child!.id!, _child!.ageInMonths);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async { setState(() => _loading = true); await _loadData(); },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Greeting
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Halo, ${_user?.name ?? 'Parents'}! 👋', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
              const SizedBox(height: 4),
              Text('Yuk, pantau perkembangan si kecil hari ini', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textMuted)),
            ])),
            CircleAvatar(radius: 24, backgroundColor: AppColors.primaryPale, child: Icon(Icons.person, color: AppColors.primaryDark)),
          ]),
          const SizedBox(height: 20),

          // Child profile card
          if (_child != null) _buildChildCard()
          else _buildAddChildCard(),
          const SizedBox(height: 20),

          // Progress section
          if (_child != null) ...[
            Text('Progress Perkembangan', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 12),
            _buildProgressCard(),
            const SizedBox(height: 20),
          ],

          // Tips
          Text('Tips Hari Ini 💡', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ..._tips.map((t) => _buildTipCard(t)),
        ]),
      ),
    );
  }

  Widget _buildChildCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryDark, Color(0xFF2D8F6A)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(children: [
        Row(children: [
          CircleAvatar(radius: 30, backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Icon(_child!.gender == 'Laki-laki' ? Icons.boy_rounded : Icons.girl_rounded, size: 35, color: Colors.white)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_child!.name, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text(_child!.shortAgeString, style: GoogleFonts.nunito(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
              child: Text(_child!.gender, style: GoogleFonts.nunito(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ])),
          GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, '/child_profile', arguments: _child);
              _loadData();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _infoItem('Berat', '${_child!.weight?.toStringAsFixed(1) ?? '-'} kg', Icons.monitor_weight_outlined),
            Container(width: 1, height: 35, color: Colors.white.withValues(alpha: 0.3)),
            _infoItem('Tinggi', '${_child!.height?.toStringAsFixed(1) ?? '-'} cm', Icons.height_rounded),
            Container(width: 1, height: 35, color: Colors.white.withValues(alpha: 0.3)),
            _infoItem('Status', _child!.nutritionStatus, Icons.favorite_rounded),
          ]),
        ),
      ]),
    );
  }

  Widget _infoItem(String label, String value, IconData icon) {
    return Column(children: [
      Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
      Text(label, style: GoogleFonts.nunito(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
    ]);
  }

  Widget _buildAddChildCard() {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, '/child_profile');
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: Column(children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: AppColors.primaryPale.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: const Icon(Icons.add_rounded, size: 30, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 12),
          Text('Tambahkan Data Anak', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
          const SizedBox(height: 4),
          Text('Mulai pantau tumbuh kembang si kecil', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
        ]),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        CustomProgressBar(label: 'Motorik', percentage: _progress['motorik'] ?? 0, icon: Icons.directions_run_rounded, color: const Color(0xFF4CAF50)),
        CustomProgressBar(label: 'Kognitif', percentage: _progress['kognitif'] ?? 0, icon: Icons.psychology_rounded, color: const Color(0xFF2196F3)),
        CustomProgressBar(label: 'Bahasa', percentage: _progress['bahasa'] ?? 0, icon: Icons.record_voice_over_rounded, color: const Color(0xFFFF9800)),
        CustomProgressBar(label: 'Sosial & Emosional', percentage: _progress['sosial_emosional'] ?? 0, icon: Icons.people_rounded, color: const Color(0xFFE91E63)),
      ]),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 45, height: 45,
          decoration: BoxDecoration(color: AppColors.primaryPale.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
          child: Icon(tip['icon'] as IconData, color: AppColors.primaryDark, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tip['title'] as String, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 3),
          Text(tip['desc'] as String, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textMuted, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}
