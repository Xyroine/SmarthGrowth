import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.monitor_heart_rounded,
      title: 'Pantau Perkembangan',
      desc: 'Monitor tumbuh kembang si kecil dengan mudah. Catat milestone motorik, kognitif, bahasa, dan sosial-emosional.',
    ),
    _OnboardingData(
      icon: Icons.menu_book_rounded,
      title: 'Edukasi Terpercaya',
      desc: 'Dapatkan artikel edukasi seputar parenting, kesehatan, dan tumbuh kembang anak dari sumber terpercaya.',
    ),
    _OnboardingData(
      icon: Icons.show_chart_rounded,
      title: 'Grafik Pertumbuhan',
      desc: 'Lihat grafik pertumbuhan berat dan tinggi badan anak untuk memastikan tumbuh kembang yang optimal.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.bgCream, Color(0xFFF0FFF7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skip,
                  child: Text('Lewati', style: GoogleFonts.nunito(
                    color: AppColors.textMuted, fontWeight: FontWeight.w600,
                  )),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => _buildPage(_pages[i]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppColors.primary : AppColors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < 2) {
                      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                    } else {
                      _skip();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(_currentPage < 2 ? 'Lanjut' : 'Mulai Sekarang',
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              color: AppColors.primaryPale.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 70, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 40),
          Text(data.title, style: GoogleFonts.montserrat(
            fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primaryDark,
          ), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(data.desc, style: GoogleFonts.nunito(
            fontSize: 15, color: AppColors.textMuted, height: 1.6,
          ), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String desc;
  _OnboardingData({required this.icon, required this.title, required this.desc});
}
