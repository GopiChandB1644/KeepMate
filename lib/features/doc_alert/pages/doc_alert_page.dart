import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../tracked_items/cubit/items_cubit.dart';
import '../../tracked_items/cubit/items_state.dart';

class DocAlertPage extends StatelessWidget {
  const DocAlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KeepRemindAppBar(
        title: 'DocAlert',
        subtitle: 'Licences, passports & vehicle documents',
        showBack: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push(AppRoutes.addItem, extra: ItemSubcategory.document),
        backgroundColor: AppColors.docAlertColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Document',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              description:
                  'Save your driving licence, car insurance, PUC, RC book, and passport to avoid sudden penalties.',
              actionLabel: 'Add Document Now',
              onAction: () => context.push(AppRoutes.addItem,
                  extra: ItemSubcategory.document),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: docItems.length,
            itemBuilder: (context, index) {
              final item = docItems[index];
              return ItemSummaryCard(
                item: item,
                onTap: () => context.push(AppRoutes.itemDetail, extra: item),
                quickActionLabel: 'Renew',
                onQuickAction: () =>
                    context.push(AppRoutes.renewal, extra: item),
              );
            },
          );
        },
      ),
    );
  }
}
