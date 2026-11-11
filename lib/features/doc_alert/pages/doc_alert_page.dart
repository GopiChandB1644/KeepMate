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
import '../../tracked_items/pages/renewal_flow_page.dart';

class DocAlertPage extends StatelessWidget {
  const DocAlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocAlert'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditItemPage(initialSubcategory: ItemSubcategory.document),
            ),
          );
        },
        backgroundColor: AppColors.docAlertColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Document', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, state) {
          final docItems = state.items.where((e) {
            return e.category == ItemCategory.docAlert ||
                e.subcategory == ItemSubcategory.document ||
                e.subcategory == ItemSubcategory.insurance;
          }).toList();

          if (docItems.isEmpty) {
            return EmptyStateView(
              icon: Icons.badge_rounded,
              title: 'No vehicle or identity documents yet',
              description: 'Save your driving licence, car insurance, PUC, RC book, and passport to avoid sudden penalties.',
              actionLabel: 'Add Document Now',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditItemPage(initialSubcategory: ItemSubcategory.document),
                  ),
                );
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: docItems.length,
            itemBuilder: (context, index) {
              final item = docItems[index];
              return ItemSummaryCard(
                item: item,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ItemDetailPage(item: item)),
                  );
                },
                quickActionLabel: 'Renew',
                onQuickAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RenewalFlowPage(item: item)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
