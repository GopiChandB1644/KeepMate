import 'package:flutter/material.dart';
import '../../../../core/design_system/app_colors.dart';

class HomeFeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color lightBgColor;
  final Color darkBgColor;
  final Color lightBorderColor;
  final Color darkBorderColor;
  final VoidCallback onTap;

  const HomeFeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.lightBgColor,
    required this.darkBgColor,
    required this.lightBorderColor,
    required this.darkBorderColor,
    required this.onTap,
  });
}

class HomeFeatureCard extends StatelessWidget {
  final HomeFeatureItem item;

  const HomeFeatureCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;
    final bgColor = isDark ? item.darkBgColor : item.lightBgColor;
    final borderColor = isDark ? item.darkBorderColor : item.lightBorderColor;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: item.iconColor,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
