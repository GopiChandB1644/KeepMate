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

class FreshCheckPage extends StatefulWidget {
  const FreshCheckPage({super.key});

  @override
  State<FreshCheckPage> createState() => _FreshCheckPageState();
}

class _FreshCheckPageState extends State<FreshCheckPage> {
  StorageLocation? _selectedStorage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KeepRemindAppBar(
        title: 'FreshCheck',
        subtitle: 'Pantry, fridge & food expiry',
        showBack: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          AppRoutes.addItem,
          extra: ItemSubcategory.grocery,
        ),
        backgroundColor: AppColors.freshCheckColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Grocery / Food',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, state) {
          final freshItems = state.items
              .where((e) => e.category == ItemCategory.freshCheck)
              .toList();
          final displayed = _selectedStorage == null
              ? freshItems
              : freshItems.where((e) {
                  final loc = e.groceryDetails?.storageLocation;
                  return loc == _selectedStorage?.code;
                }).toList();

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
              // Storage Location Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _filterChip(
                      label: 'All Places (${freshItems.length})',
                      selected: _selectedStorage == null,
                      onSelected: () => setState(() => _selectedStorage = null),
                    ),
                    const SizedBox(width: 8),
                    ...StorageLocation.values.map((loc) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _filterChip(
                          label: loc.label,
                          selected: _selectedStorage == loc,
                          onSelected: () =>
                              setState(() => _selectedStorage = loc),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Summary counter
              if (displayed.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${displayed.length} grocery items',
                        style: AppText.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          if (urgentCount > 0) ...[
                            Text(
                              '$urgentCount expiring today',
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
                        icon: Icons.kitchen_outlined,
                        title: 'No groceries or products added',
                        description:
                            'Track milk, vegetables, medicines & food batches before they expire.',
                        actionLabel: 'Add Grocery Item',
                        onAction: () => context.push(
                          AppRoutes.addItem,
                          extra: ItemSubcategory.grocery,
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
                            quickActionLabel: item.status != ItemStatus.consumed
                                ? 'Used Up'
                                : null,
                            onQuickAction: item.status != ItemStatus.consumed
                                ? () => context
                                    .read<ItemsCubit>()
                                    .markConsumed(item.id)
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
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      showCheckmark: false,
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.freshCheckColor.withValues(alpha: 0.12),
      backgroundColor: context.surfaceColor,
      side: BorderSide(
        color: selected
            ? AppColors.freshCheckColor.withValues(alpha: 0.6)
            : context.cardBorderColor,
      ),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? AppColors.freshCheckColor : AppColors.textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      onSelected: (_) => onSelected(),
    );
  }
}
