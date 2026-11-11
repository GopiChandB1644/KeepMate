import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../tracked_items/cubit/items_cubit.dart';
import '../../tracked_items/cubit/items_state.dart';
import '../../tracked_items/pages/add_edit_item_page.dart';
import '../../tracked_items/pages/item_detail_page.dart';

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
      appBar: AppBar(
        title: const Text('FreshCheck'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditItemPage(initialSubcategory: ItemSubcategory.grocery),
            ),
          );
        },
        backgroundColor: AppColors.freshCheckColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Grocery / Food', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, state) {
          final freshItems = state.items.where((e) => e.category == ItemCategory.freshCheck).toList();
          final displayed = _selectedStorage == null
              ? freshItems
              : freshItems.where((e) {
                  final loc = e.groceryDetails?.storageLocation;
                  return loc == _selectedStorage?.code;
                }).toList();

          return Column(
            children: [
              // Storage Location Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Places'),
                      selected: _selectedStorage == null,
                      onSelected: (_) => setState(() => _selectedStorage = null),
                    ),
                    const SizedBox(width: 8),
                    ...StorageLocation.values.map((loc) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(loc.label),
                          selected: _selectedStorage == loc,
                          onSelected: (_) => setState(() => _selectedStorage = loc),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              Expanded(
                child: displayed.isEmpty
                    ? EmptyStateView(
                        icon: Icons.kitchen_rounded,
                        title: 'No groceries or products added',
                        description: 'Track milk, vegetables, medicines & food batches before they expire.',
                        actionLabel: 'Add Grocery Item',
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddEditItemPage(initialSubcategory: ItemSubcategory.grocery),
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
                            quickActionLabel: item.status != ItemStatus.consumed ? 'Used Up' : null,
                            onQuickAction: item.status != ItemStatus.consumed
                                ? () => context.read<ItemsCubit>().markConsumed(item.id)
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
