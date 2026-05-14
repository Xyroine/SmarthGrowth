import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = DatabaseHelper();
  AppUser? _user;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadUser(); }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) _user = await _db.getUserById(userId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      child: Column(children: [
        // Profile header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primaryDark, Color(0xFF2D8F6A)]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 5))],
          ),
          child: Column(children: [
            CircleAvatar(radius: 40, backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Icon(Icons.person_rounded, size: 45, color: Colors.white)),
            const SizedBox(height: 14),
            Text(_user?.name ?? 'User', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text(_user?.email ?? '', style: GoogleFonts.nunito(fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
          ]),
        ),
        const SizedBox(height: 24),

        // Menu items
        _buildSection('Akun', [
          _menuItem(Icons.person_outline_rounded, 'Informasi Akun', () {}),
          _menuItem(Icons.child_care_rounded, 'Profil Anak', () => Navigator.pushNamed(context, '/child_profile')),
          _menuItem(Icons.show_chart_rounded, 'Grafik Pertumbuhan', () => Navigator.pushNamed(context, '/growth_chart')),
        ]),
        const SizedBox(height: 16),
        _buildSection('Data & Privasi', [
          _menuItem(Icons.shield_outlined, 'Kebijakan Privasi', () {}),
          _menuItem(Icons.description_outlined, 'Syarat & Ketentuan', () {}),
        ]),
        const SizedBox(height: 16),
        _buildSection('Pengaturan', [
          _menuItem(Icons.notifications_outlined, 'Notifikasi', () {}),
          _menuItem(Icons.language_rounded, 'Bahasa', () {}),
          _menuItem(Icons.help_outline_rounded, 'Bantuan', () {}),
          _menuItem(Icons.info_outline_rounded, 'Tentang Aplikasi', () => _showAbout()),
        ]),
        const SizedBox(height: 24),

        // Logout button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            label: Text('Keluar', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // App info
        Text('SmartGrowth v1.0.0', style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text('SDG 3 & SDG 4', style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: items),
      ),
    ]);
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: AppColors.primaryPale.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primaryDark, size: 20),
      ),
      title: Text(title, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showAbout() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Tentang SmartGrowth', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 18)),
      content: Text('SmartGrowth adalah aplikasi monitoring dan edukasi tumbuh kembang balita yang sejalan dengan SDG 3 (Kesehatan) dan SDG 4 (Pendidikan Anak Usia Dini).\n\nVersi 1.0.0',
        style: GoogleFonts.nunito(fontSize: 13, height: 1.5, color: AppColors.textMuted)),
      actions: [TextButton(onPressed: () => Navigator.pop(context),
        child: Text('Tutup', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.primary)))],
    ));
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Keluar?', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 18)),
      content: Text('Apakah Anda yakin ingin keluar?', style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textMuted)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: GoogleFonts.nunito(color: AppColors.textMuted))),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Keluar', style: GoogleFonts.nunito(color: Colors.red, fontWeight: FontWeight.w700))),
      ],
    ));
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }
}
