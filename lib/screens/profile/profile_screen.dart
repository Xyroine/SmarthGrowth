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
  void initState() {
    super.initState();
    _loadUser();
  }

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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: [
          // Profile header (Sage Pastel card, radius 24)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textDark.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person_rounded, size: 45, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _user?.name ?? 'User',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.email ?? '',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
              label: Text('Keluar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App info
          Text('SmartGrowth v1.0.0', style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text('SDG 3 & SDG 4', style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        Container(
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
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _showAbout() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: AppColors.bgCream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Tentang SmartGrowth',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textDark),
              ),
              content: Text(
                'SmartGrowth adalah aplikasi monitoring dan edukasi tumbuh kembang balita yang sejalan dengan SDG 3 (Kesehatan) dan SDG 4 (Pendidikan Anak Usia Dini).\n\nVersi 1.0.0',
                style: GoogleFonts.nunito(fontSize: 13, height: 1.5, color: AppColors.textMuted),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                )
              ],
            ));
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: AppColors.bgCream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Keluar?',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textDark),
              ),
              content: Text(
                'Apakah Anda yakin ingin keluar?',
                style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textMuted),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Batal', style: GoogleFonts.nunito(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Keluar',
                    style: GoogleFonts.nunito(color: Colors.red, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ));
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }
}
