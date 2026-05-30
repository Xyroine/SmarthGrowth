import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/monitoring/monitoring_screen.dart';
import '../screens/education/education_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/custom_navbar.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    MonitoringScreen(),
    EducationScreen(),
    ProfileScreen(),
  ];

  final _titles = ['Beranda', 'Monitoring', 'Edukasi', 'Profil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: _currentIndex == 0 
          ? null 
          : AppBar(
              backgroundColor: AppColors.bgCream,
              elevation: 0,
              title: Text(
                _titles[_currentIndex],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              centerTitle: false,
            ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
