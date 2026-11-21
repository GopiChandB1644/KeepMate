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

class LifePocketPage extends StatefulWidget {
  const LifePocketPage({super.key});

  @override
  State<LifePocketPage> createState() => _LifePocketPageState();
}

class _LifePocketPageState extends State<LifePocketPage> {
  ItemSubcategory? _selectedSubFilter;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const KeepRemindAppBar(
        title: 'LifePocket',
        subtitle: 'Bills, warranties & subscriptions',
        showBack: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          AppRoutes.addItem,
          extra: _selectedSubFilter ?? ItemSubcategory.bill,
        ),
        backgroundColor: AppColors.lifePocketColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Bill / Warranty',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, state) {
          final lifePocketItems = state.items
              .where((e) => e.category == ItemCategory.lifePocket)
              .toList();
          final displayed = _selectedSubFilter == null
              ? lifePocketItems
              : lifePocketItems
                  .where((e) => e.subcategory == _selectedSubFilter)
                  .toList();

          final activeCount =
              displayed.where((e) => e.status == ItemStatus.active).length;
          final urgentCount = displayed
              .where((e) =>
                  e.status == ItemStatus.dueToday ||
                  e.status == ItemStatus.expired)
              .length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean Filter Chips Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _filterChip(
                      label: 'All (${lifePocketItems.length})',
                      selected: _selectedSubFilter == null,
                      onSelected: () =>
                          setState(() => _selectedSubFilter = null),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Bills',
                      icon: Icons.receipt_long_outlined,
                      selected: _selectedSubFilter == ItemSubcategory.bill,
                      onSelected: () => setState(
                          () => _selectedSubFilter = ItemSubcategory.bill),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Warranties',
                      icon: Icons.verified_user_outlined,
                      selected: _selectedSubFilter == ItemSubcategory.warranty,
                      onSelected: () => setState(
                          () => _selectedSubFilter = ItemSubcategory.warranty),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Insurance',
                      icon: Icons.health_and_safety_outlined,
                      selected: _selectedSubFilter == ItemSubcategory.insurance,
                      onSelected: () => setState(
                          () => _selectedSubFilter = ItemSubcategory.insurance),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Subscriptions',
                      icon: Icons.autorenew_rounded,
                      selected:
                          _selectedSubFilter == ItemSubcategory.subscription,
                      onSelected: () => setState(() =>
                          _selectedSubFilter = ItemSubcategory.subscription),
                    ),
                  ],
                ),
              ),

              // Summary bar if items present
              if (displayed.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${displayed.length} items',
                        style: AppText.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          if (urgentCount > 0) ...[
                            Text(
                              '$urgentCount need attention',
                              style: AppText.bodySmall.copyWith(
                                color: AppColors.dangerRed,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '$activeCount active',
                            style: AppText.bodySmall.copyWith(
                              color: AppColors.safeGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: displayed.isEmpty
                    ? EmptyStateView(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'No items in LifePocket',
                        description:
                            'Never miss an electricity bill, wifi payment, or appliance warranty expiry again.',
                        actionLabel: 'Add First Item',
                        onAction: () => context.push(
                          AppRoutes.addItem,
                          extra: _selectedSubFilter ?? ItemSubcategory.bill,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 88),
                        itemCount: displayed.length,
                        itemBuilder: (context, index) {
                          final item = displayed[index];
                          return ItemSummaryCard(
                            item: item,
                            onTap: () =>
                                context.push(AppRoutes.itemDetail, extra: item),
                            quickActionLabel:
                                item.subcategory == ItemSubcategory.bill &&
                                        item.status != ItemStatus.completed
                                    ? 'Mark Paid'
                                    : null,
                            onQuickAction: item.subcategory ==
                                        ItemSubcategory.bill &&
                                    item.status != ItemStatus.completed
                                ? () =>
                                    context.read<ItemsCubit>().markPaid(item.id)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip({
    required String label,
    IconData? icon,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      showCheckmark: false,
      avatar: icon != null
          ? Icon(
              icon,
              size: 15,
              color: selected
                  ? AppColors.lifePocketColor
                  : AppColors.textSecondary,
            )
          : null,
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.lifePocketColor.withValues(alpha: 0.12),
      backgroundColor: context.surfaceColor,
      side: BorderSide(
        color: selected
            ? AppColors.lifePocketColor.withValues(alpha: 0.6)
            : context.cardBorderColor,
      ),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? AppColors.lifePocketColor : AppColors.textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      onSelected: (_) => onSelected(),
    );
  }
}
