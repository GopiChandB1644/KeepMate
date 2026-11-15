import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../medicine_care/cubit/medicine_cubit.dart';
import '../../medicine_care/cubit/medicine_state.dart';
import '../../medicine_care/domain/entities/dose_log_entity.dart';
import '../../tracked_items/cubit/items_cubit.dart';
import '../../tracked_items/cubit/items_state.dart';
import '../widgets/home_feature_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ItemCategory _selectedCategory = ItemCategory.lifePocket;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemsCubit, ItemsState>(
      builder: (context, state) {
        return BlocBuilder<MedicineCubit, MedicineState>(
          builder: (context, medState) {
            final cubit = context.read<ItemsCubit>();
            final tabItems = state.items.where((e) => e.category == _selectedCategory).toList();
            final urgentTabItems = tabItems
                .where((e) =>
                    e.status == ItemStatus.dueToday ||
                    e.status == ItemStatus.upcoming ||
                    e.status == ItemStatus.expired)
                .toList();

            final tabDueToday = tabItems.where((e) => e.status == ItemStatus.dueToday).length;
            final tabUpcoming = tabItems.where((e) => e.status == ItemStatus.upcoming).length;
            final tabActive = tabItems.where((e) => e.status == ItemStatus.active).length;

            final fabConfig = _getFabConfig();

            return Scaffold(
              appBar: KeepRemindAppBar(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 20),
                ),
                title: 'KeepRemind',
                subtitle: 'Never miss an expiry or bill',
                showBack: false,
                actions: [
                  CircleIconButton(
                    icon: Icons.search_rounded,
                    size: 40,
                    tooltip: 'Search',
                    onTap: () => context.push(AppRoutes.search),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: fabConfig.onTap,
                backgroundColor: fabConfig.color,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  fabConfig.label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  // 1. Top Segmented Category Tabs
                  _buildCategorySegmentedControl(state, medState),

                  const SizedBox(height: 16),

                  // 2. Quick Status Counters for selected tab
                  if (_selectedCategory == ItemCategory.medicineCare)
                    Row(
                      children: [
                        _statusCounterCard(
                          label: 'Taken',
                          count: medState.takenCount,
                          color: AppColors.safeGreen,
                        ),
                        const SizedBox(width: 10),
                        _statusCounterCard(
                          label: 'Pending',
                          count: medState.pendingCount,
                          color: AppColors.infoBlue,
                        ),
                        const SizedBox(width: 10),
                        _statusCounterCard(
                          label: 'Unconfirmed',
                          count: medState.unconfirmedCount,
                          color: AppColors.dangerRed,
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        _statusCounterCard(
                          label: 'Due Today',
                          count: tabDueToday,
                          color: AppColors.dangerRed,
                        ),
                        const SizedBox(width: 10),
                        _statusCounterCard(
                          label: 'Due Soon',
                          count: tabUpcoming,
                          color: AppColors.warningOrange,
                        ),
                        const SizedBox(width: 10),
                        _statusCounterCard(
                          label: 'Active',
                          count: tabActive,
                          color: AppColors.safeGreen,
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // 3. Tab Section Header
                  _buildCategoryHeader(),

                  const SizedBox(height: 12),

                  // 4. 2x2 Feature Action Cards Grid
                  _buildFeatureCardsGrid(),

                  const SizedBox(height: 24),

                  // 5. Category-Specific Body
                  if (_selectedCategory == ItemCategory.medicineCare) ...[
                    _buildMedicineCareHomeSection(context, medState),
                  ] else ...[
                    // Urgent / Action Required Items for this tab
                    if (urgentTabItems.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.notification_important_rounded, color: AppColors.dangerRed, size: 22),
                          const SizedBox(width: 8),
                          Text('Action Required', style: AppText.h3),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...urgentTabItems.map((item) {
                        return ItemSummaryCard(
                          item: item,
                          onTap: () => context.push(AppRoutes.itemDetail, extra: item),
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

                    // All Tracked Items in this tab
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedCategory.displayName} Items (${tabItems.length})',
                          style: AppText.h3,
                        ),
                        if (tabItems.isNotEmpty)
                          Text(
                            '$tabActive active',
                            style: AppText.bodySmall.copyWith(color: AppColors.safeGreen, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (tabItems.isEmpty)
                      _buildEmptyState()
                    else
                      ...tabItems.map((item) {
                        return ItemSummaryCard(
                          item: item,
                          onTap: () => context.push(AppRoutes.itemDetail, extra: item),
                          quickActionLabel: item.subcategory == ItemSubcategory.bill && item.status != ItemStatus.completed
                              ? 'Mark Paid'
                              : item.subcategory == ItemSubcategory.grocery && item.status != ItemStatus.consumed
                                  ? 'Used Up'
                                  : null,
                          onQuickAction: item.subcategory == ItemSubcategory.bill && item.status != ItemStatus.completed
                              ? () => cubit.markPaid(item.id)
                              : item.subcategory == ItemSubcategory.grocery && item.status != ItemStatus.consumed
                                  ? () => cubit.markConsumed(item.id)
                                  : null,
                        );
                      }),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Segmented Control with pills matching brand colors
  Widget _buildCategorySegmentedControl(ItemsState state, MedicineState medState) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _categoryTabPill(
            category: ItemCategory.lifePocket,
            label: 'LifePocket',
            icon: Icons.account_balance_wallet_rounded,
            activeColor: AppColors.lifePocketColor,
            count: state.items.where((e) => e.category == ItemCategory.lifePocket).length,
          ),
          const SizedBox(width: 4),
          _categoryTabPill(
            category: ItemCategory.freshCheck,
            label: 'FreshCheck',
            icon: Icons.apple_rounded,
            activeColor: AppColors.freshCheckColor,
            count: state.items.where((e) => e.category == ItemCategory.freshCheck).length,
          ),
          const SizedBox(width: 4),
          _categoryTabPill(
            category: ItemCategory.docAlert,
            label: 'DocAlert',
            icon: Icons.shield_rounded,
            activeColor: AppColors.docAlertColor,
            count: state.items.where((e) => e.category == ItemCategory.docAlert).length,
          ),
          const SizedBox(width: 4),
          _categoryTabPill(
            category: ItemCategory.medicineCare,
            label: 'MedicineCare',
            icon: Icons.medication_rounded,
            activeColor: AppColors.medicineCareColor,
            count: medState.medicines.length,
          ),
        ],
      ),
    );
  }

  Widget _categoryTabPill({
    required ItemCategory category,
    required String label,
    required IconData icon,
    required Color activeColor,
    required int count,
  }) {
    final isSelected = _selectedCategory == category;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedCategory = category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? activeColor : AppColors.textMuted,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? activeColor : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    final String title;
    final String subtitle;
    switch (_selectedCategory) {
      case ItemCategory.lifePocket:
        title = 'LifePocket';
        subtitle = 'YOUR PERSONAL ORGANIZER';
        break;
      case ItemCategory.freshCheck:
        title = 'FreshCheck';
        subtitle = 'FOOD EXPIRIES & PANTRY ORGANIZER';
        break;
      case ItemCategory.docAlert:
        title = 'DocAlert';
        subtitle = 'IDENTITY, VEHICLE & OFFICIAL DOCUMENTS';
        break;
      case ItemCategory.medicineCare:
        title = 'MedicineCare';
        subtitle = 'MEDICINE SCHEDULES & FAMILY REMINDERS';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.6),
        ),
      ],
    );
  }

  /// 2x2 Feature Cards Grid matching the user's reference image
  Widget _buildFeatureCardsGrid() {
    final List<HomeFeatureItem> cards = _getFeatureItemsForTab();

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: HomeFeatureCard(item: cards[0])),
            const SizedBox(width: 12),
            Expanded(child: HomeFeatureCard(item: cards[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: HomeFeatureCard(item: cards[2])),
            const SizedBox(width: 12),
            Expanded(child: HomeFeatureCard(item: cards[3])),
          ],
        ),
      ],
    );
  }

  List<HomeFeatureItem> _getFeatureItemsForTab() {
    switch (_selectedCategory) {
      case ItemCategory.lifePocket:
        return [
          HomeFeatureItem(
            title: 'Bills & Receipts',
            subtitle: 'Purchase records',
            icon: Icons.receipt_long_rounded,
            iconColor: const Color(0xFF2563EB),
            lightBgColor: const Color(0xFFEFF6FF),
            darkBgColor: const Color(0xFF1E293B),
            lightBorderColor: const Color(0xFFDBEAFE),
            darkBorderColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
            onTap: () => context.push(
              AppRoutes.addItem,
              extra: {'subcategory': ItemSubcategory.bill, 'title': ''},
            ),
          ),
          HomeFeatureItem(
            title: 'Warranties',
            subtitle: 'Product protection',
            icon: Icons.verified_user_rounded,
            iconColor: const Color(0xFF16A34A),
            lightBgColor: const Color(0xFFF0FDF4),
            darkBgColor: const Color(0xFF14532D).withValues(alpha: 0.35),
            lightBorderColor: const Color(0xFFDCFCE7),
            darkBorderColor: const Color(0xFF16A34A).withValues(alpha: 0.4),
            onTap: () => context.push(
              AppRoutes.addItem,
              extra: {'subcategory': ItemSubcategory.warranty, 'title': ''},
            ),
          ),
          HomeFeatureItem(
            title: 'Subscriptions',
            subtitle: 'Recurring payments',
            icon: Icons.autorenew_rounded,
            iconColor: const Color(0xFFD97706),
            lightBgColor: const Color(0xFFFEFCE8),
            darkBgColor: const Color(0xFF713F12).withValues(alpha: 0.35),
            lightBorderColor: const Color(0xFFFEF08A),
            darkBorderColor: const Color(0xFFD97706).withValues(alpha: 0.4),
            onTap: () => context.push(
              AppRoutes.addItem,
              extra: {'subcategory': ItemSubcategory.subscription, 'title': ''},
            ),
          ),
          HomeFeatureItem(
            title: 'Payments',
            subtitle: 'Upcoming dues',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF9333EA),
            lightBgColor: const Color(0xFFFAF5FF),
            darkBgColor: const Color(0xFF3B0764).withValues(alpha: 0.35),
            lightBorderColor: const Color(0xFFF3E8FF),
            darkBorderColor: const Color(0xFF9333EA).withValues(alpha: 0.4),
            onTap: () => context.push(
              AppRoutes.addItem,
              extra: {'subcategory': ItemSubcategory.insurance, 'title': ''},
            ),
          ),
        ];

      case ItemCategory.freshCheck:
        return [
          HomeFeatureItem(
            title: 'Dairy & Fridge',
            subtitle: 'Milk & perishables',
            icon: Icons.kitchen_rounded,
            iconColor: const Color(0xFF2563EB),
            lightBgColor: const Color(0xFFEFF6FF),
            darkBgColor: const Color(0xFF1E293B),
            lightBorderColor: const Color(0xFFDBEAFE),
            darkBorderColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
            onTap: () => context.push(
              AppRoutes.addItem,
              extra: {
                'subcategory': ItemSubcategory.grocery,
                'storageLocation': StorageLocation.fridge,
                'title': 'Milk / Dairy',
              },
            ),
          ),
          HomeFeatureItem(
            title: 'Pantry & Staples',
            subtitle: 'Grains & snacks',
            icon: Icons.inventory_2_rounded,
            iconColor: const Color(0xFFD97706),
            lightBgColor: const Color(0xFFFEFCE8),
            darkBgColor: const Color(0xFF713F12).withValues(alpha: 0.35),
            lightBorderColor: const Color(0xFFFEF08A),
            darkBorderColor: const Color(0xFFD97706).withValues(alpha: 0.4),
            onTap: () => context.push(
              AppRoutes.addItem,
              extra: {
                'subcategory': ItemSubcategory.grocery,
                'storageLocation': StorageLocation.pantry,
              },
            ),
          ),
          HomeFeatureItem(
            title: 'Fruits & Veggies',
            subtitle: 'Fresh farm produce',
            icon: Icons.apple_rounded,
            iconColor: const Color(0xFF16A34A),
            lightBgColor: const Color(0xFFF0FDF4),
            darkBgColor: const Color(0xFF14532D).withValues(alpha: 0.35),
            lightBorderColor: const Color(0xFFDCFCE7),
            darkBorderColor: const Color(0xFF16A34A).withValues(alpha: 0.4),
            onTap: () => context.push(
              AppRoutes.addItem,
              extra: {
                'subcategory': ItemSubcategory.grocery,
                'storageLocation': StorageLocation.fridge,
                'title': 'Fresh Produce',
              },
            ),
          ),
          HomeFeatureItem(
            title: 'Medicines & Care',
            subtitle: 'Tablets & syrups',
            icon: Icons.medication_rounded,
            iconColor: const Color(0xFF9333EA),
            lightBgColor: const Color(0xFFFAF5FF),
            darkBgColor: const Color(0xFF3B0764).withValues(alpha: 0.35),
            lightBorderColor: const Color(0xFFF3E8FF),
            darkBorderColor: const Color(0xFF9333EA).withValues(alpha: 0.4),
            onTap: () => context.push(
              AppRoutes.addItem,
              extra: {
                'subcategory': ItemSubcategory.grocery,
                'storageLocation': StorageLocation.medicineBox,
                'title': 'Medicine / Syrup',
              },
            ),
          ),
        ];

      case ItemCategory.docAlert:
        return [
          HomeFeatureItem(
            title: 'Driving Licence',
            subtitle: 'DL smart card & info',
            icon: Icons.badge_rounded,
            iconColor: const Color(0xFF2563EB),
            lightBgColor: const Color(0xFFEFF6FF),
            darkBgColor: const Color(0xFF1E293B),
            lightBorderColor: const Color(0xFFDBEAFE),
            darkBorderColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
            onTap: () => context.push(
              AppRoutes.addItem,
              extra: {
                'subcategory': ItemSubcategory.document,
                'title': 'Driving Licence',
              },
            ),
          ),
          HomeFeatureItem(
            title: 'Vehicle RC & PUC',
            subtitle: 'Registration & emission',
            icon: Icons.directions_car_rounded,
            iconColor: const Color(0xFF16A34A),
            lightBgColor: const Color(0xFFF0FDF4),
            darkBgColor: const Color(0xFF14532D).withValues(alpha: 0.35),
            lightBorderColor: const Color(0xFFDCFCE7),
            darkBorderColor: const Color(0xFF16A34A).withValues(alpha: 0.4),
            onTap: () => context.push(
              AppRoutes.addItem,
              extra: {
                'subcategory': ItemSubcategory.document,
                'title': 'Vehicle RC',
              },
            ),
          ),
          HomeFeatureItem(
            title: 'Passport & Visa',
            subtitle: 'Travel & official IDs',
            icon: Icons.flight_takeoff_rounded,
            iconColor: const Color(0xFFD97706),
            lightBgColor: const Color(0xFFFEFCE8),
            darkBgColor: const Color(0xFF713F12).withValues(alpha: 0.35),
            lightBorderColor: const Color(0xFFFEF08A),
            darkBorderColor: const Color(0xFFD97706).withValues(alpha: 0.4),
            onTap: () => context.push(
              AppRoutes.addItem,
              extra: {
                'subcategory': ItemSubcategory.document,
                'title': 'Passport',
              },
            ),
          ),
          HomeFeatureItem(
            title: 'Identity & Cards',
            subtitle: 'Aadhaar, PAN & certificates',
            icon: Icons.credit_card_rounded,
            iconColor: const Color(0xFF9333EA),
            lightBgColor: const Color(0xFFFAF5FF),
            darkBgColor: const Color(0xFF3B0764).withValues(alpha: 0.35),
            lightBorderColor: const Color(0xFFF3E8FF),
            darkBorderColor: const Color(0xFF9333EA).withValues(alpha: 0.4),
            onTap: () => context.push(
              AppRoutes.addItem,
              extra: {
                'subcategory': ItemSubcategory.document,
                'title': 'Identity Card',
              },
            ),
          ),
        ];

      case ItemCategory.medicineCare:
        return [
          HomeFeatureItem(
            title: "Today's Doses",
            subtitle: 'Next & pending pills',
            icon: Icons.alarm_rounded,
            iconColor: const Color(0xFF2563EB),
            lightBgColor: const Color(0xFFEFF6FF),
            darkBgColor: const Color(0xFF1E293B),
            lightBorderColor: const Color(0xFFDBEAFE),
            darkBorderColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
            onTap: () => context.push(AppRoutes.medicineToday),
          ),
          HomeFeatureItem(
            title: 'Add Medicine',
            subtitle: 'Prescription & timings',
            icon: Icons.medication_rounded,
            iconColor: const Color(0xFF16A34A),
            lightBgColor: const Color(0xFFF0FDF4),
            darkBgColor: const Color(0xFF14532D).withValues(alpha: 0.35),
            lightBorderColor: const Color(0xFFDCFCE7),
            darkBorderColor: const Color(0xFF16A34A).withValues(alpha: 0.4),
            onTap: () => context.push(AppRoutes.medicineAdd),
          ),
          HomeFeatureItem(
            title: 'Dose History',
            subtitle: 'Adherence logs',
            icon: Icons.history_rounded,
            iconColor: const Color(0xFFD97706),
            lightBgColor: const Color(0xFFFEFCE8),
            darkBgColor: const Color(0xFF713F12).withValues(alpha: 0.35),
            lightBorderColor: const Color(0xFFFEF08A),
            darkBorderColor: const Color(0xFFD97706).withValues(alpha: 0.4),
            onTap: () => context.push(AppRoutes.medicineHistory),
          ),
          HomeFeatureItem(
            title: 'Family Care',
            subtitle: 'Caregiver alerts',
            icon: Icons.family_restroom_rounded,
            iconColor: const Color(0xFF9333EA),
            lightBgColor: const Color(0xFFFAF5FF),
            darkBgColor: const Color(0xFF3B0764).withValues(alpha: 0.35),
            lightBorderColor: const Color(0xFFF3E8FF),
            darkBorderColor: const Color(0xFF9333EA).withValues(alpha: 0.4),
            onTap: () => context.push(AppRoutes.medicineFamily),
          ),
        ];
    }
  }

  _FabConfig _getFabConfig() {
    switch (_selectedCategory) {
      case ItemCategory.lifePocket:
        return _FabConfig(
          label: '+ Add Bill / Warranty',
          color: AppColors.lifePocketColor,
          onTap: () => context.push(
            AppRoutes.addItem,
            extra: {'subcategory': ItemSubcategory.bill},
          ),
        );
      case ItemCategory.freshCheck:
        return _FabConfig(
          label: '+ Add Food / Grocery',
          color: AppColors.freshCheckColor,
          onTap: () => context.push(
            AppRoutes.addItem,
            extra: {'subcategory': ItemSubcategory.grocery},
          ),
        );
      case ItemCategory.docAlert:
        return _FabConfig(
          label: '+ Add Document',
          color: AppColors.docAlertColor,
          onTap: () => context.push(
            AppRoutes.addItem,
            extra: {'subcategory': ItemSubcategory.document},
          ),
        );
      case ItemCategory.medicineCare:
        return _FabConfig(
          label: '+ Add Medicine',
          color: AppColors.medicineCareColor,
          onTap: () => context.push(AppRoutes.medicineAdd),
        );
    }
  }

  Widget _buildEmptyState() {
    final String title;
    final String description;
    final IconData icon;

    switch (_selectedCategory) {
      case ItemCategory.lifePocket:
        title = 'No LifePocket items yet';
        description = 'Tap "Bills & Receipts" or "Warranties" above to track your first bill, appliance warranty, or subscription.';
        icon = Icons.receipt_long_rounded;
        break;
      case ItemCategory.freshCheck:
        title = 'No food items yet';
        description = 'Tap "Dairy & Fridge" or "Pantry & Staples" above to track milk, fresh veggies, or medicine expiries.';
        icon = Icons.kitchen_rounded;
        break;
      case ItemCategory.docAlert:
        title = 'No documents saved yet';
        description = 'Tap "Driving Licence" or "Vehicle RC" above to store your document and never miss a renewal deadline.';
        icon = Icons.shield_rounded;
        break;
      case ItemCategory.medicineCare:
        title = 'No medicines scheduled';
        description = 'Tap "Add Medicine" above or the button below to set up your prescription schedule and daily reminders.';
        icon = Icons.medication_rounded;
        break;
    }

    return EmptyStateView(
      icon: icon,
      title: title,
      description: description,
      actionLabel: 'Add First Item',
      actionIcon: Icons.add_rounded,
      onAction: _getFabConfig().onTap,
    );
  }

  Widget _buildMedicineCareHomeSection(BuildContext context, MedicineState medState) {
    final nextDose = medState.nextDose;
    final todayDoses = medState.todayDoses;
    final cubit = context.read<MedicineCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Next Dose Hero Banner if exists
        if (nextDose != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.medicineCareColor,
                  AppColors.medicineCareColor.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.medicineCareColor.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.alarm_rounded, color: Colors.white, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'UPCOMING DOSE',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDoseTime(nextDose.scheduledTime),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  nextDose.medicine.name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '${nextDose.medicine.dosage} • ${nextDose.medicine.instructions.label}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.medicineCareColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text('Mark Taken', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: () => cubit.markDoseTaken(nextDose),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      onPressed: () => cubit.snoozeDose(nextDose, minutes: 15),
                      child: const Text('Snooze 15m', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Schedule Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Schedule (${todayDoses.length})", style: AppText.h3),
            if (todayDoses.isNotEmpty)
              TextButton(
                onPressed: () => context.push(AppRoutes.medicineToday),
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (todayDoses.isEmpty)
          _buildEmptyState()
        else
          ...todayDoses.map((dose) => _buildMedicineScheduleCard(context, dose)),
      ],
    );
  }

  String _formatDoseTime(String hhmm) {
    try {
      final parts = hhmm.split(':');
      final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    } catch (_) {
      return hhmm;
    }
  }

  Widget _buildMedicineScheduleCard(BuildContext context, DoseLogEntity dose) {
    final cubit = context.read<MedicineCubit>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.medicineCareColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                dose.medicine.medicineType.icon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dose.medicine.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${dose.medicine.dosage} • ${dose.medicine.instructions.label}',
                  style: AppText.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDoseTime(dose.scheduledTime),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (dose.isTaken)
                const Text('✓ Taken', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.safeGreen))
              else if (dose.status == DoseStatus.snoozed)
                const Text('⏰ Snoozed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent))
              else if (dose.isSkipped)
                Text('✕ Skipped', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))
              else
                InkWell(
                  onTap: () => cubit.markDoseTaken(dose),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.medicineCareColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Take Dose',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.medicineCareColor),
                    ),
                  ),
                ),
            ],
          ),
        ],
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
}

class _FabConfig {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FabConfig({
    required this.label,
    required this.color,
    required this.onTap,
  });
}
