import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int? _selectedChildId;

  final _titles = ['Beranda', 'Monitoring', 'Edukasi', 'Profil'];

  @override
  void initState() {
    super.initState();
    _loadSelectedChildId();
  }

  Future<void> _loadSelectedChildId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedChildId = prefs.getInt('selected_child_id');
      });
    }
  }

  void _handleChildChanged(int? childId) {
    setState(() {
      _selectedChildId = childId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        selectedChildId: _selectedChildId,
        onChildChanged: _handleChildChanged,
      ),
      MonitoringScreen(
        selectedChildId: _selectedChildId,
        onChildChanged: _handleChildChanged,
      ),
      const EducationScreen(),
      ProfileScreen(
        selectedChildId: _selectedChildId,
        onChildChanged: _handleChildChanged,
      ),
    ];

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
        children: screens,
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: _currentIndex,
        onTap: (i) {
          _loadSelectedChildId();
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}
