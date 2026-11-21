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

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  ItemCategory? _selectedCategory;
  bool _showUrgentOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KeepRemindAppBar(
        title: 'Search',
        subtitle: 'Find bills, warranties, groceries & docs',
        showBack: true,
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, state) {
          final query = _searchController.text.trim().toLowerCase();

          final filtered = state.items.where((item) {
            // 1. Filter by category if selected
            if (_selectedCategory != null &&
                item.category != _selectedCategory) {
              return false;
            }

            // 2. Filter by urgent status if toggled
            if (_showUrgentOnly &&
                item.status != ItemStatus.dueToday &&
                item.status != ItemStatus.upcoming &&
                item.status != ItemStatus.expired) {
              return false;
            }

            // 3. Search query matching across title, subcategory, description, provider, doc number, vehicle
            if (query.isNotEmpty) {
              final titleMatch = item.title.toLowerCase().contains(query);
              final descMatch =
                  item.description?.toLowerCase().contains(query) ?? false;
              final subMatch =
                  item.subcategory.displayName.toLowerCase().contains(query);
              final catMatch =
                  item.category.displayName.toLowerCase().contains(query);
              final docNumMatch =
                  item.documentNumber?.toLowerCase().contains(query) ?? false;
              final providerMatch =
                  item.providerOrSeller?.toLowerCase().contains(query) ?? false;
              final vehicleMatch =
                  item.vehicleNumber?.toLowerCase().contains(query) ?? false;

              return titleMatch ||
                  descMatch ||
                  subMatch ||
                  catMatch ||
                  docNumMatch ||
                  providerMatch ||
                  vehicleMatch;
            }

            return true;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Box
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText:
                        'Search by item name, provider, or DL/doc number...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    fillColor: context.surfaceColor,
                  ),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    _filterChip(
                      label: 'All Items',
                      isSelected: _selectedCategory == null && !_showUrgentOnly,
                      onTap: () {
                        setState(() {
                          _selectedCategory = null;
                          _showUrgentOnly = false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'LifePocket',
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.lifePocketColor,
                      isSelected: _selectedCategory == ItemCategory.lifePocket,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              _selectedCategory == ItemCategory.lifePocket
                                  ? null
                                  : ItemCategory.lifePocket;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'FreshCheck',
                      icon: Icons.apple_rounded,
                      color: AppColors.freshCheckColor,
                      isSelected: _selectedCategory == ItemCategory.freshCheck,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              _selectedCategory == ItemCategory.freshCheck
                                  ? null
                                  : ItemCategory.freshCheck;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'DocAlert',
                      icon: Icons.shield_rounded,
                      color: AppColors.docAlertColor,
                      isSelected: _selectedCategory == ItemCategory.docAlert,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              _selectedCategory == ItemCategory.docAlert
                                  ? null
                                  : ItemCategory.docAlert;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Due Soon / Urgent',
                      icon: Icons.priority_high_rounded,
                      color: AppColors.dangerRed,
                      isSelected: _showUrgentOnly,
                      onTap: () {
                        setState(() {
                          _showUrgentOnly = !_showUrgentOnly;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Results Count Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Text(
                  query.isEmpty
                      ? (_selectedCategory != null || _showUrgentOnly
                          ? '${filtered.length} filtered ${filtered.length == 1 ? 'item' : 'items'}'
                          : 'All Tracked Items (${filtered.length})')
                      : '${filtered.length} ${filtered.length == 1 ? 'result' : 'results'} for "$query"',
                  style: AppText.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),

              const Divider(height: 12),

              // Results List or Empty State
              Expanded(
                child: filtered.isEmpty
                    ? (query.isNotEmpty
                        ? EmptyStateView(
                            icon: Icons.search_off_rounded,
                            title: 'No matches found',
                            description:
                                'We couldn\'t find anything matching "$query". Try adjusting your search query or filters.',
                            actionLabel: 'Clear Search',
                            actionIcon: Icons.clear_rounded,
                            onAction: () {
                              _searchController.clear();
                              setState(() {
                                _selectedCategory = null;
                                _showUrgentOnly = false;
                              });
                            },
                          )
                        : EmptyStateView(
                            icon: Icons.inventory_2_outlined,
                            title: 'No items in this filter',
                            description:
                                'No tracked records match the current filter selection.',
                            actionLabel: 'Reset Filters',
                            actionIcon: Icons.filter_alt_off_rounded,
                            onAction: () {
                              setState(() {
                                _selectedCategory = null;
                                _showUrgentOnly = false;
                              });
                            },
                          ))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ItemSummaryCard(
                            item: item,
                            onTap: () =>
                                context.push(AppRoutes.itemDetail, extra: item),
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
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    Color? color,
  }) {
    final activeColor = color ?? AppColors.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.12)
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : context.cardBorderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 16,
                  color: isSelected ? activeColor : AppColors.textMuted),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
