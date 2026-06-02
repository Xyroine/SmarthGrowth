import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/user.dart';
import '../../models/child_profile.dart';

class ProfileScreen extends StatefulWidget {
  final int? selectedChildId;
  final ValueChanged<int?>? onChildChanged;

  const ProfileScreen({
    super.key,
    this.selectedChildId,
    this.onChildChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = DatabaseHelper();
  AppUser? _user;
  List<ChildProfile> _children = [];
  bool _loading = true;

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedChildId != oldWidget.selectedChildId) {
      setState(() => _loading = true);
      _loadData();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      _user = await _db.getUserById(userId);
      _children = await _db.getChildren(userId);
    }
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

          // Profil Anak section — show all children
          _buildChildrenSection(),
          const SizedBox(height: 16),

          // Menu items
          _buildSection('Akun', [
            _menuItem(Icons.person_outline_rounded, 'Informasi Akun', () {}),
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

  /// Section that displays all registered children with edit & add functionality
  Widget _buildChildrenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profil Anak',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.pushNamed(context, '/child_profile');
                  if (result == true) {
                    final prefs = await SharedPreferences.getInstance();
                    final currentSelectedId = prefs.getInt('selected_child_id');
                    widget.onChildChanged?.call(currentSelectedId);
                  }
                  setState(() => _loading = true);
                  _loadData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Tambah',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_children.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
              children: [
                Icon(Icons.child_care_rounded, size: 40, color: AppColors.textMuted.withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                Text(
                  'Belum ada data anak',
                  style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/child_profile');
                    setState(() => _loading = true);
                    _loadData();
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('Tambah Anak', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
          )
        else
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
            child: Column(
              children: _children.asMap().entries.map((entry) {
                final index = entry.key;
                final child = entry.value;
                final isBoy = child.gender == 'Laki-laki';
                final avatarColor = isBoy ? const Color(0xFF42A5F5) : const Color(0xFFEC407A);
                final isSelected = widget.selectedChildId == child.id;

                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.05) : null,
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: avatarColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: avatarColor.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: Icon(
                          isBoy ? Icons.boy_rounded : Icons.girl_rounded,
                          color: avatarColor,
                          size: 26,
                        ),
                      ),
                      title: Text(
                        child.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: Text(
                        '${child.shortAgeString} • ${child.gender}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Aktif',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // Weight/height badge
                          if (child.weight != null && child.height != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${child.weight?.toStringAsFixed(1)} kg',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
                        ],
                      ),
                      onTap: () async {
                        final result = await Navigator.pushNamed(context, '/child_profile', arguments: child);
                        if (result == true) {
                          final prefs = await SharedPreferences.getInstance();
                          final currentSelectedId = prefs.getInt('selected_child_id');
                          widget.onChildChanged?.call(currentSelectedId);
                        }
                        setState(() => _loading = true);
                        _loadData();
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    if (index < _children.length - 1)
                      Divider(
                        height: 1,
                        indent: 72,
                        endIndent: 16,
                        color: AppColors.divider.withValues(alpha: 0.5),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
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
      await prefs.remove('selected_child_id');
      widget.onChildChanged?.call(null);
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }
}
