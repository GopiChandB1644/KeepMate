import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../doc_alert/pages/doc_alert_page.dart';
import '../../fresh_check/pages/fresh_check_page.dart';
import '../../life_pocket/pages/life_pocket_page.dart';
import '../../tracked_items/cubit/items_cubit.dart';
import '../../tracked_items/cubit/items_state.dart';

class CategoriesHubPage extends StatelessWidget {
  const CategoriesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KeepRemindAppBar(
        title: 'Categories',
        subtitle: 'All items organized by type',
      ),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, state) {
          final lifePocketCount = state.items.where((e) => e.category == ItemCategory.lifePocket).length;
          final freshCheckCount = state.items.where((e) => e.category == ItemCategory.freshCheck).length;
          final docAlertCount = state.items.where((e) => e.category == ItemCategory.docAlert).length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Choose a Category', style: AppText.h2),
              const SizedBox(height: 6),
              Text('Organized neatly so you can find anything instantly.', style: AppText.bodyMedium),
              const SizedBox(height: 24),

              _CategoryCard(
                title: 'LifePocket',
                subtitle: 'Bills, warranties, gadgets & recurring subscriptions',
                count: lifePocketCount,
                color: AppColors.lifePocketColor,
                icon: Icons.account_balance_wallet_rounded,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LifePocketPage()));
                },
              ),
              const SizedBox(height: 16),

              _CategoryCard(
                title: 'FreshCheck',
                subtitle: 'Milk, vegetables, food expiry batches & pantry storage',
                count: freshCheckCount,
                color: AppColors.freshCheckColor,
                icon: Icons.kitchen_rounded,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FreshCheckPage()));
                },
              ),
              const SizedBox(height: 16),

              _CategoryCard(
                title: 'DocAlert',
                subtitle: 'Driving licence, vehicle insurance, PUC & passport',
                count: docAlertCount,
                color: AppColors.docAlertColor,
                icon: Icons.shield_rounded,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DocAlertPage()));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(title, style: AppText.h2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$count items',
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(subtitle, style: AppText.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

