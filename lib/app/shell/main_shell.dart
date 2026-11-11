import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/app_colors.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  index: 0,
                  label: 'Home',
                  icon: Icons.home_rounded,
                  activeIcon: Icons.home_rounded,
                ),
                _navItem(
                  index: 1,
                  label: 'Categories',
                  icon: Icons.grid_view_rounded,
                  activeIcon: Icons.grid_view_rounded,
                ),
                _navItem(
                  index: 2,
                  label: 'Vault',
                  icon: Icons.folder_shared_rounded,
                  activeIcon: Icons.folder_shared_rounded,
                ),
                _navItem(
                  index: 3,
                  label: 'Settings',
                  icon: Icons.settings_rounded,
                  activeIcon: Icons.settings_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = navigationShell.currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textMuted;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

