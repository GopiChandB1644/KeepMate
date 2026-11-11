import 'package:flutter/material.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text.dart';
import '../../core/enums/item_enums.dart';
import '../../features/tracked_items/domain/entities/tracked_item_entity.dart';
import 'status_chip.dart';

class ItemSummaryCard extends StatelessWidget {
  final TrackedItemEntity item;
  final VoidCallback onTap;
  final VoidCallback? onQuickAction;
  final String? quickActionLabel;

  const ItemSummaryCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onQuickAction,
    this.quickActionLabel,
  });

  IconData get _icon {
    switch (item.subcategory) {
      case ItemSubcategory.bill:
        return Icons.receipt_long_rounded;
      case ItemSubcategory.warranty:
        return Icons.verified_user_rounded;
      case ItemSubcategory.insurance:
        return Icons.health_and_safety_rounded;
      case ItemSubcategory.subscription:
        return Icons.subscriptions_rounded;
      case ItemSubcategory.purchase:
        return Icons.shopping_bag_rounded;
      case ItemSubcategory.grocery:
        return Icons.apple_rounded;
      case ItemSubcategory.document:
        return Icons.badge_rounded;
    }
  }

  Color get _iconColor {
    switch (item.category) {
      case ItemCategory.lifePocket:
        return AppColors.lifePocketColor;
      case ItemCategory.freshCheck:
        return AppColors.freshCheckColor;
      case ItemCategory.docAlert:
        return AppColors.docAlertColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_icon, color: _iconColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppText.h3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subcategory.displayName,
                            style: AppText.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    StatusChip(status: item.status),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_rounded,
                          size: 16,
                          color: item.status == ItemStatus.expired || item.status == ItemStatus.dueToday
                              ? AppColors.dangerRed
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.relativeTimeLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: item.status == ItemStatus.expired || item.status == ItemStatus.dueToday
                                ? AppColors.dangerRed
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (onQuickAction != null && quickActionLabel != null)
                      TextButton.icon(
                        onPressed: onQuickAction,
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: Text(quickActionLabel!),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                          foregroundColor: AppColors.primary,
                        ),
                      )
                    else
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

