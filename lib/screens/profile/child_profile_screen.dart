import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/child_profile.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({super.key});
  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  String _gender = 'Laki-laki';
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365));
  ChildProfile? _existing;
  bool _isLoading = false;
  bool _initialized = false;

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ChildProfile) {
      _existing = arg;
      _nameCtrl.text = arg.name;
      _gender = arg.gender;
      _birthDate = arg.birthDate;
      _weightCtrl.text = arg.weight?.toString() ?? '';
      _heightCtrl.text = arg.height?.toString() ?? '';
      if (arg.photoPath != null && arg.photoPath!.isNotEmpty) {
        final f = File(arg.photoPath!);
        if (f.existsSync()) _imageFile = f;
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, maxWidth: 800);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: Text('Pilih dari Galeri', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: AppColors.primary),
              title: Text('Ambil dari Kamera', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppColors.bgCream,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text(
          _existing != null ? 'Edit Profil Anak' : 'Tambah Anak',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textDark.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.secondary,
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null
                            ? Icon(
                                _gender == 'Laki-laki' ? Icons.boy_rounded : Icons.girl_rounded,
                                size: 55,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showPickerOptions,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _label('Nama Anak'),
              TextFormField(
                controller: _nameCtrl,
                decoration: _deco('Masukkan nama anak', Icons.person_outline),
                style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark),
                validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 18),
              _label('Jenis Kelamin'),
              Row(
                children: [
                  Expanded(child: _genderCard('Laki-laki', Icons.boy_rounded, const Color(0xFF42A5F5))),
                  const SizedBox(width: 12),
                  Expanded(child: _genderCard('Perempuan', Icons.girl_rounded, const Color(0xFFEC407A))),
                ],
              ),
              const SizedBox(height: 18),
              _label('Tanggal Lahir'),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMMM yyyy').format(_birthDate),
                        style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Berat (kg)'),
                      TextFormField(
                        controller: _weightCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark),
                        decoration: _deco('kg', Icons.monitor_weight_outlined),
                      ),
                    ],
                  )),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Tinggi (cm)'),
                      TextFormField(
                        controller: _heightCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark),
                        decoration: _deco('cm', Icons.height_rounded),
                      ),
                    ],
                  )),
                ],
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          'Simpan',
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              if (_existing != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _delete,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Hapus Profil Anak',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          t,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textDark,
          ),
        ),
      );

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(fontSize: 14, color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  Widget _genderCard(String label, IconData icon, Color color) {
    final sel = _gender == label;
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel ? color : AppColors.divider.withValues(alpha: 0.8),
            width: sel ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: sel ? color : AppColors.textMuted, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: sel ? color : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.bgCream,
            onSurface: AppColors.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _birthDate = d);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Data Anak?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textDark),
        ),
        content: Text(
          'Data "${_existing!.name}" beserta semua riwayat milestone dan pertumbuhan akan dihapus secara permanen.',
          style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.nunito(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: GoogleFonts.nunito(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final db = DatabaseHelper();
      await db.deleteChild(_existing!.id!);
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getInt('selected_child_id') == _existing!.id) {
        await prefs.remove('selected_child_id');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Data anak berhasil dihapus'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id')!;
    final db = DatabaseHelper();
    final child = ChildProfile(
      id: _existing?.id,
      userId: userId,
      name: _nameCtrl.text.trim(),
      gender: _gender,
      birthDate: _birthDate,
      weight: double.tryParse(_weightCtrl.text),
      height: double.tryParse(_heightCtrl.text),
      photoPath: _imageFile?.path ?? _existing?.photoPath,
    );
    if (_existing != null) {
      await db.updateChild(child);
    } else {
      final newId = await db.insertChild(child);
      // Auto-select the newly created child
      await prefs.setInt('selected_child_id', newId);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Data anak berhasil disimpan!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context, true);
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }
}
