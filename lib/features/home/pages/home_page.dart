import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../tracked_items/cubit/items_cubit.dart';
import '../../tracked_items/cubit/items_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KeepRemindAppBar(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 20),
        ),
        title: 'KeepRemind',
        subtitle: 'Never miss an expiry or bill',
        showBack: false,
        actions: [
          CircleIconButton(
            icon: Icons.search_rounded,
            size: 40,
            tooltip: 'Search',
            onTap: () => context.push(AppRoutes.search),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addItem),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, state) {
          final cubit = context.read<ItemsCubit>();
          final urgent = state.urgentItems;
          final all = state.items;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              // Quick Status Counters
              Row(
                children: [
                  _statusCounterCard(
                    label: 'Due Today',
                    count: state.dueTodayCount,
                    color: AppColors.dangerRed,
                  ),
                  const SizedBox(width: 10),
                  _statusCounterCard(
                    label: 'Due Soon',
                    count: state.upcomingCount,
                    color: AppColors.warningOrange,
                  ),
                  const SizedBox(width: 10),
                  _statusCounterCard(
                    label: 'Active',
                    count: state.activeCount,
                    color: AppColors.safeGreen,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Fast Module Navigation Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quick Categories', style: AppText.h3),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.categories),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  _categoryQuickBtn(
                    label: 'LifePocket',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.lifePocketColor,
                    onTap: () => context.push(AppRoutes.lifePocket),
                  ),
                  const SizedBox(width: 10),
                  _categoryQuickBtn(
                    label: 'FreshCheck',
                    icon: Icons.apple_rounded,
                    color: AppColors.freshCheckColor,
                    onTap: () => context.push(AppRoutes.freshCheck),
                  ),
                  const SizedBox(width: 10),
                  _categoryQuickBtn(
                    label: 'DocAlert',
                    icon: Icons.shield_rounded,
                    color: AppColors.docAlertColor,
                    onTap: () => context.push(AppRoutes.docAlert),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Urgent Items Section
              if (urgent.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.notification_important_rounded, color: AppColors.dangerRed, size: 22),
                    const SizedBox(width: 8),
                    Text('Action Required', style: AppText.h3),
                  ],
                ),
                const SizedBox(height: 12),
                ...urgent.map((item) {
                  return ItemSummaryCard(
                    item: item,
                    onTap: () => context.push(AppRoutes.itemDetail, extra: item),
                    quickActionLabel: item.subcategory == ItemSubcategory.bill
                        ? 'Mark Paid'
                        : item.subcategory == ItemSubcategory.grocery
                            ? 'Used Up'
                            : null,
                    onQuickAction: item.subcategory == ItemSubcategory.bill
                        ? () => cubit.markPaid(item.id)
                        : item.subcategory == ItemSubcategory.grocery
                            ? () => cubit.markConsumed(item.id)
                            : null,
                  );
                }),
                const SizedBox(height: 16),
              ],

              // All Tracked Items
              Text('All Tracked Items (${all.length})', style: AppText.h3),
              const SizedBox(height: 12),

              if (all.isEmpty)
                EmptyStateView(
                  icon: Icons.inventory_2_outlined,
                  title: 'Nothing tracked yet',
                  description: 'Tap "+ Add Item" below to start tracking your bills, food expiries, or vehicle documents!',
                  actionLabel: 'Add First Item',
                  onAction: () => context.push(AppRoutes.addItem),
                )
              else
                ...all.map((item) {
                  return ItemSummaryCard(
                    item: item,
                    onTap: () => context.push(AppRoutes.itemDetail, extra: item),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _statusCounterCard({required String label, required int count, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppText.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryQuickBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
