import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, Color(0xFF1E6B4C)],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo & Title
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15)],
                  ),
                  child: const Icon(Icons.child_care_rounded, size: 40, color: AppColors.primaryDark),
                ),
                const SizedBox(height: 16),
                Text('SmartGrowth', style: GoogleFonts.montserrat(
                  fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white,
                )),
                const SizedBox(height: 6),
                Text('Masuk ke akun Anda', style: GoogleFonts.nunito(
                  fontSize: 14, color: Colors.white.withValues(alpha: 0.85),
                )),
                const SizedBox(height: 30),
                // Form Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Masukkan email',
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textMuted, size: 20),
                            filled: true, fillColor: AppColors.inputBg.withValues(alpha: 0.5),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Email wajib diisi' : null,
                        ),
                        const SizedBox(height: 18),
                        Text('Password', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Masukkan password',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textMuted, size: 20),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true, fillColor: AppColors.inputBg.withValues(alpha: 0.5),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Password wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 24, height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Ingat saya', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: Text('Lupa kata sandi?', style: GoogleFonts.nunito(
                                fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600,
                              )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 3,
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : Text('Masuk', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.divider.withValues(alpha: 0.5))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('atau', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
                            ),
                            Expanded(child: Divider(color: AppColors.divider.withValues(alpha: 0.5))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton(Icons.g_mobiledata_rounded, const Color(0xFFDB4437)),
                            const SizedBox(width: 16),
                            _socialButton(Icons.facebook_rounded, const Color(0xFF4267B2)),
                            const SizedBox(width: 16),
                            _socialButton(Icons.apple_rounded, Colors.black),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum memiliki akun? ', style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: Text('Daftar', style: GoogleFonts.nunito(
                        color: AppColors.accentYellow, fontWeight: FontWeight.w800, fontSize: 14,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08), shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final db = DatabaseHelper();
      final user = await db.getUser(_emailController.text.trim(), _passwordController.text);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', user.id!);
        if (mounted) Navigator.pushReplacementNamed(context, '/main');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email atau password salah'), backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
