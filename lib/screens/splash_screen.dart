import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      final seen = prefs.getBool('onboarding_seen') ?? false;
      Navigator.pushReplacementNamed(context, seen ? '/login' : '/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, Color(0xFF1A6B4A), AppColors.primary],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
                  ),
                  child: const Icon(Icons.child_care_rounded, size: 60, color: AppColors.primaryDark),
                ),
                const SizedBox(height: 24),
                Text('SmartGrowth', style: GoogleFonts.montserrat(
                  fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white,
                  letterSpacing: 1.2,
                )),
                const SizedBox(height: 8),
                Text('Monitoring Tumbuh Kembang Balita', style: GoogleFonts.nunito(
                  fontSize: 14, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500,
                )),
                const SizedBox(height: 60),
                SizedBox(
                  width: 30, height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3, color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
