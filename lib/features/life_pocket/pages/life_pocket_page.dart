import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../tracked_items/cubit/items_cubit.dart';
import '../../tracked_items/cubit/items_state.dart';
import '../../tracked_items/pages/add_edit_item_page.dart';
import '../../tracked_items/pages/item_detail_page.dart';

class LifePocketPage extends StatefulWidget {
  const LifePocketPage({super.key});

  @override
  State<LifePocketPage> createState() => _LifePocketPageState();
}

class _LifePocketPageState extends State<LifePocketPage> {
  ItemSubcategory? _selectedSubFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KeepRemindAppBar(
        title: 'LifePocket',
        subtitle: 'Bills, warranties & subscriptions',
        showBack: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditItemPage(initialSubcategory: _selectedSubFilter ?? ItemSubcategory.bill),
            ),
          );
        },
        backgroundColor: AppColors.lifePocketColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Bill / Warranty', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, state) {
          final lifePocketItems = state.items.where((e) => e.category == ItemCategory.lifePocket).toList();
          final displayed = _selectedSubFilter == null
              ? lifePocketItems
              : lifePocketItems.where((e) => e.subcategory == _selectedSubFilter).toList();

          return Column(
            children: [
              // Subcategory Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedSubFilter == null,
                      onSelected: (_) => setState(() => _selectedSubFilter = null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('⚡ Bills'),
                      selected: _selectedSubFilter == ItemSubcategory.bill,
                      onSelected: (_) => setState(() => _selectedSubFilter = ItemSubcategory.bill),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('🛡️ Warranties'),
                      selected: _selectedSubFilter == ItemSubcategory.warranty,
                      onSelected: (_) => setState(() => _selectedSubFilter = ItemSubcategory.warranty),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('🩺 Insurance'),
                      selected: _selectedSubFilter == ItemSubcategory.insurance,
                      onSelected: (_) => setState(() => _selectedSubFilter = ItemSubcategory.insurance),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('🔁 Subscriptions'),
                      selected: _selectedSubFilter == ItemSubcategory.subscription,
                      onSelected: (_) => setState(() => _selectedSubFilter = ItemSubcategory.subscription),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: displayed.isEmpty
                    ? EmptyStateView(
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'No items in LifePocket',
                        description: 'Never miss an electricity bill, wifi payment, or warranty expiry again.',
                        actionLabel: 'Add First Item',
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditItemPage(initialSubcategory: _selectedSubFilter ?? ItemSubcategory.bill),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: displayed.length,
                        itemBuilder: (context, index) {
                          final item = displayed[index];
                          return ItemSummaryCard(
                            item: item,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ItemDetailPage(item: item)),
                              );
                            },
                            quickActionLabel: item.subcategory == ItemSubcategory.bill && item.status != ItemStatus.completed
                                ? 'Mark Paid'
                                : null,
                            onQuickAction: item.subcategory == ItemSubcategory.bill && item.status != ItemStatus.completed
                                ? () => context.read<ItemsCubit>().markPaid(item.id)
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
}
