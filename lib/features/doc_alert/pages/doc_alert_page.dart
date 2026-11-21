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

class DocAlertPage extends StatefulWidget {
  const DocAlertPage({super.key});

  @override
  State<DocAlertPage> createState() => _DocAlertPageState();
}

class _DocAlertPageState extends State<DocAlertPage> {
  String?
      _selectedFilter; // null = all, 'dl_vehicle', 'passport_id', 'insurance'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KeepRemindAppBar(
        title: 'DocAlert',
        subtitle: 'Licences, passports & vehicle documents',
        showBack: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          AppRoutes.addItem,
          extra: ItemSubcategory.document,
        ),
        backgroundColor: AppColors.docAlertColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Document',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, state) {
          final allDocItems = state.items.where((e) {
            return e.category == ItemCategory.docAlert ||
                e.subcategory == ItemSubcategory.document ||
                e.subcategory == ItemSubcategory.insurance;
          }).toList();

          final displayed = allDocItems.where((e) {
            if (_selectedFilter == 'dl_vehicle') {
              final title = e.title.toLowerCase();
              return title.contains('dl') ||
                  title.contains('driving') ||
                  title.contains('licence') ||
                  title.contains('license') ||
                  title.contains('rc') ||
                  title.contains('puc') ||
                  title.contains('vehicle');
            } else if (_selectedFilter == 'passport_id') {
              final title = e.title.toLowerCase();
              return title.contains('passport') ||
                  title.contains('visa') ||
                  title.contains('aadhaar') ||
                  title.contains('pan') ||
                  title.contains('id') ||
                  title.contains('identity');
            } else if (_selectedFilter == 'insurance') {
              return e.subcategory == ItemSubcategory.insurance ||
                  e.title.toLowerCase().contains('insurance');
            }
            return true;
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
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _filterChip(
                      label: 'All (${allDocItems.length})',
                      selected: _selectedFilter == null,
                      onSelected: () => setState(() => _selectedFilter = null),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Licences & Vehicle',
                      icon: Icons.directions_car_outlined,
                      selected: _selectedFilter == 'dl_vehicle',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'dl_vehicle'),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Passports & IDs',
                      icon: Icons.badge_outlined,
                      selected: _selectedFilter == 'passport_id',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'passport_id'),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Insurance',
                      icon: Icons.health_and_safety_outlined,
                      selected: _selectedFilter == 'insurance',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'insurance'),
                    ),
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
                        '${displayed.length} documents',
                        style: AppText.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          if (urgentCount > 0) ...[
                            Text(
                              '$urgentCount expiring soon',
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
                        icon: Icons.badge_outlined,
                        title: allDocItems.isEmpty
                            ? 'No vehicle or identity documents yet'
                            : 'No matching documents',
                        description: allDocItems.isEmpty
                            ? 'Save your driving licence, car insurance, PUC, RC book, and passport to avoid sudden penalties.'
                            : 'Try selecting another document filter above.',
                        actionLabel: 'Add Document Now',
                        onAction: () => context.push(
                          AppRoutes.addItem,
                          extra: ItemSubcategory.document,
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
                            quickActionLabel: 'Renew',
                            onQuickAction: () =>
                                context.push(AppRoutes.renewal, extra: item),
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
              color:
                  selected ? AppColors.docAlertColor : AppColors.textSecondary,
            )
          : null,
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.docAlertColor.withValues(alpha: 0.12),
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: selected
            ? AppColors.docAlertColor.withValues(alpha: 0.6)
            : AppColors.cardBorder,
      ),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? AppColors.docAlertColor : AppColors.textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      onSelected: (_) => onSelected(),
    );
  }
}
