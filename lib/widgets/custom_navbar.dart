import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavbar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Beranda', 0),
              _buildNavItem(Icons.monitor_heart_rounded, 'Monitoring', 1),
              _buildNavItem(Icons.menu_book_rounded, 'Edukasi', 2),
              _buildNavItem(Icons.person_rounded, 'Profil', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: isSelected ? 26 : 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              color: Colors.white,
              fontSize: isSelected ? 11 : 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            )),
          ],
        ),
      ),
    );
  }
}
