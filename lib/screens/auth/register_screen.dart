import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true, _obscure2 = true, _agree = false, _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, Color(0xFF1E6B4C)], stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15)],
                  ),
                  child: const Icon(Icons.child_care_rounded, size: 35, color: AppColors.primaryDark),
                ),
                const SizedBox(height: 12),
                Text('Buat Akun Baru', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Daftar untuk mulai memantau si kecil', style: GoogleFonts.nunito(fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Nama Lengkap'),
                        _field(_nameController, 'Masukkan nama lengkap', Icons.person_outline, validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null),
                        const SizedBox(height: 16),
                        _label('Email'),
                        _field(_emailController, 'Masukkan email', Icons.email_outlined, type: TextInputType.emailAddress, validator: (v) => v == null || v.isEmpty ? 'Email wajib diisi' : null),
                        const SizedBox(height: 16),
                        _label('Password'),
                        _field(_passwordController, 'Masukkan password', Icons.lock_outline, obscure: _obscure1, toggleObscure: () => setState(() => _obscure1 = !_obscure1), validator: (v) => v != null && v.length < 6 ? 'Minimal 6 karakter' : null),
                        const SizedBox(height: 16),
                        _label('Konfirmasi Password'),
                        _field(_confirmController, 'Konfirmasi password', Icons.lock_outline, obscure: _obscure2, toggleObscure: () => setState(() => _obscure2 = !_obscure2), validator: (v) => v != _passwordController.text ? 'Password tidak cocok' : null),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(width: 24, height: 24, child: Checkbox(
                              value: _agree, onChanged: (v) => setState(() => _agree = v ?? false),
                              activeColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: Text.rich(TextSpan(children: [
                              TextSpan(text: 'Saya menyetujui ', style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textMuted)),
                              TextSpan(text: 'Syarat & Ketentuan', style: GoogleFonts.nunito(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ]))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity, height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading || !_agree ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              disabledBackgroundColor: AppColors.grey,
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : Text('Daftar', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Sudah punya akun? ', style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Masuk', style: GoogleFonts.nunito(color: AppColors.accentYellow, fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ]),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
  );

  Widget _field(TextEditingController c, String hint, IconData icon, {
    bool obscure = false, VoidCallback? toggleObscure, TextInputType? type,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: c, obscureText: obscure, keyboardType: type,
    decoration: InputDecoration(
      hintText: hint, prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      suffixIcon: toggleObscure != null ? IconButton(
        icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 20),
        onPressed: toggleObscure,
      ) : null,
      filled: true, fillColor: AppColors.inputBg.withValues(alpha: 0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    ),
    validator: validator,
  );

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final db = DatabaseHelper();
      final existing = await db.getUserByEmail(_emailController.text.trim());
      if (existing != null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Email sudah terdaftar'), backgroundColor: Colors.red.shade400, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
        setState(() => _isLoading = false);
        return;
      }
      await db.insertUser(AppUser(name: _nameController.text.trim(), email: _emailController.text.trim(), password: _passwordController.text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Pendaftaran berhasil! Silakan masuk.'), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red.shade400, behavior: SnackBarBehavior.floating));
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() { _nameController.dispose(); _emailController.dispose(); _passwordController.dispose(); _confirmController.dispose(); super.dispose(); }
}
