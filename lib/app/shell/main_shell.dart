import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/app_colors.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      key: const ValueKey('main_shell_pop_scope'),
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            border: Border(
              top: BorderSide(
                color: context.cardBorderColor.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(
                    index: 0,
                    label: 'Home',
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                  ),
                  _navItem(
                    index: 1,
                    label: 'Vault',
                    icon: Icons.folder_shared_outlined,
                    activeIcon: Icons.folder_shared_rounded,
                  ),
                  _navItem(
                    index: 2,
                    label: 'Settings',
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                  ),
                ],
              ),
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
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primarySubtle : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    color: color,
                    size: 23,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
