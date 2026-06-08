import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/user.dart';

class MotherProfileScreen extends StatefulWidget {
  const MotherProfileScreen({super.key});

  @override
  State<MotherProfileScreen> createState() => _MotherProfileScreenState();
}

class _MotherProfileScreenState extends State<MotherProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _db = DatabaseHelper();
  
  AppUser? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        _user = await _db.getUserById(userId);
        if (_user != null) {
          _nameCtrl.text = _user!.name;
          _emailCtrl.text = _user!.email;
          if (_user!.photoPath != null && _user!.photoPath!.isNotEmpty) {
            final f = File(_user!.photoPath!);
            if (f.existsSync()) {
              _imageFile = f;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user == null) return;

    setState(() => _isSaving = true);
    try {
      // Check if email changed and is already taken
      if (_emailCtrl.text.trim().toLowerCase() != _user!.email.toLowerCase()) {
        final existing = await _db.getUserByEmail(_emailCtrl.text.trim().toLowerCase());
        if (existing != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Email sudah digunakan oleh akun lain!'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          }
          setState(() => _isSaving = false);
          return;
        }
      }

      final updatedUser = AppUser(
        id: _user!.id,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : _user!.password,
        createdAt: _user!.createdAt,
        photoPath: _imageFile?.path,
      );

      await _db.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Profil Ibu berhasil diperbarui!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Gagal memperbarui profil. Silakan coba lagi.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
    if (mounted) {
      setState(() => _isSaving = false);
    }
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
          'Profil Ibu',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
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
                                  ? const Icon(
                                      Icons.person_rounded,
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
                    
                    _label('Nama Lengkap Ibu'),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _deco('Masukkan nama lengkap Anda', Icons.person_outline_rounded),
                      style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark),
                      validator: (v) => v == null || v.isEmpty ? 'Nama lengkap wajib diisi' : null,
                    ),
                    const SizedBox(height: 18),
                    
                    _label('Alamat Email'),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _deco('Masukkan email aktif Anda', Icons.email_outlined),
                      style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email wajib diisi';
                        if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    
                    _label('Ubah Kata Sandi (Opsional)'),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: _deco('Biarkan kosong jika tidak ingin mengubah', Icons.lock_outline_rounded),
                      style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark),
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length < 6) {
                          return 'Kata sandi minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 36),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                'Simpan Perubahan',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}
