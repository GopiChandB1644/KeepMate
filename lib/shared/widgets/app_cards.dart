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
      case ItemCategory.medicineCare:
        return AppColors.medicineCareColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent =
        item.status == ItemStatus.expired || item.status == ItemStatus.dueToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? AppColors.dangerRed.withValues(alpha: 0.35)
              : AppColors.cardBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_icon, color: _iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
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
                          const SizedBox(height: 2),
                          Text(
                            item.subcategory.displayName,
                            style: AppText.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(status: item.status),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: AppColors.cardBorder.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_rounded,
                          size: 15,
                          color: isUrgent
                              ? AppColors.dangerRed
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.relativeTimeLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isUrgent
                                ? AppColors.dangerRed
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (onQuickAction != null && quickActionLabel != null)
                      TextButton.icon(
                        onPressed: onQuickAction,
                        icon: const Icon(Icons.check_circle_outline_rounded,
                            size: 15),
                        label: Text(quickActionLabel!),
                        style: TextButton.styleFrom(
                          foregroundColor: isUrgent
                              ? AppColors.dangerRed
                              : AppColors.primary,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
