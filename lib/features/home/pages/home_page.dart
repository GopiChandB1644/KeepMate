import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../categories/pages/categories_hub_page.dart';
import '../../doc_alert/pages/doc_alert_page.dart';
import '../../fresh_check/pages/fresh_check_page.dart';
import '../../life_pocket/pages/life_pocket_page.dart';
import '../../tracked_items/cubit/items_cubit.dart';
import '../../tracked_items/cubit/items_state.dart';
import '../../tracked_items/pages/add_edit_item_page.dart';
import '../../tracked_items/pages/item_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('KeepMate'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
            tooltip: 'Add Anything',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditItemPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditItemPage()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          '+ Add Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, state) {
          final cubit = context.read<ItemsCubit>();
          final urgent = state.urgentItems;
          final all = state.displayedItems;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (val) => cubit.search(val),
                decoration: InputDecoration(
                  hintText: 'Search bills, warranties, groceries...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: state.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            cubit.search('');
                          },
                        )
                      : null,
                  fillColor: AppColors.surface,
                ),
              ),

              const SizedBox(height: 16),

              if (state.searchQuery.isEmpty) ...[
                // Urgency Headline Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: urgent.isEmpty
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFFF59E0B), const Color(0xFFDC2626)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (urgent.isEmpty ? const Color(0xFF10B981) : const Color(0xFFDC2626))
                            .withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          urgent.isEmpty ? Icons.check_circle_rounded : Icons.priority_high_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              urgent.isEmpty
                                  ? 'Everything is Safe!'
                                  : '${state.dueTodayCount + state.upcomingCount + state.expiredCount} Items Need Attention',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              urgent.isEmpty
                                  ? 'No bills or products expiring soon.'
                                  : 'Due today or upcoming in the next 7 days.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CategoriesHubPage()),
                        );
                      },
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
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LifePocketPage())),
                    ),
                    const SizedBox(width: 10),
                    _categoryQuickBtn(
                      label: 'FreshCheck',
                      icon: Icons.apple_rounded,
                      color: AppColors.freshCheckColor,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FreshCheckPage())),
                    ),
                    const SizedBox(width: 10),
                    _categoryQuickBtn(
                      label: 'DocAlert',
                      icon: Icons.shield_rounded,
                      color: AppColors.docAlertColor,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocAlertPage())),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ItemDetailPage(item: item)),
                        );
                      },
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
              ],

              if (all.isEmpty)
                EmptyStateView(
                  icon: Icons.check_circle_outline_rounded,
                  title: state.searchQuery.isNotEmpty ? 'No matches found' : 'Nothing tracked yet',
                  description: state.searchQuery.isNotEmpty
                      ? 'Try searching with a different name or keyword.'
                      : 'Tap "+ Add Item" below to start tracking your bills, food expiries, or vehicle documents!',
                  actionLabel: state.searchQuery.isNotEmpty ? null : 'Add First Item',
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddEditItemPage()),
                    );
                  },
                )
              else
                ...all.map((item) {
                  return ItemSummaryCard(
                    item: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ItemDetailPage(item: item)),
                      );
                    },
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

