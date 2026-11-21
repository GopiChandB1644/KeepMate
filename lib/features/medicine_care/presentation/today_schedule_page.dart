import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../cubit/medicine_cubit.dart';
import '../cubit/medicine_state.dart';
import '../domain/entities/dose_log_entity.dart';
import '../domain/entities/medicine_entity.dart';

class TodaySchedulePage extends StatefulWidget {
  const TodaySchedulePage({super.key});

  @override
  State<TodaySchedulePage> createState() => _TodaySchedulePageState();
}

class _TodaySchedulePageState extends State<TodaySchedulePage> {
  int _selectedTab = 0; // 0: Daily Doses, 1: All Prescriptions

  String _formatTime12Hour(String hhmm) {
    try {
      final parts = hhmm.split(':');
      final time =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    } catch (_) {
      return hhmm;
    }
  }

  void _showSkipDialog(BuildContext context, DoseLogEntity dose) {
    final reasonController = TextEditingController();
    final commonReasons = [
      'Felt nauseous / sick',
      'Doctor advised to stop',
      'Forgot / away from home',
      'Fasting'
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Skip Dose Reason'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why is ${dose.medicine.name} being skipped?',
              style: AppText.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: commonReasons.map((r) {
                return ActionChip(
                  label: Text(r, style: const TextStyle(fontSize: 12.5)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  onPressed: () {
                    reasonController.text = r;
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Enter reason or select above',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
            onPressed: () async {
              final reason = reasonController.text.trim();
              Navigator.pop(ctx);
              await context.read<MedicineCubit>().markDoseSkipped(dose,
                  reason: reason.isNotEmpty ? reason : null);
              if (context.mounted) {
                showToast(context, 'Dose marked as skipped',
                    type: ToastType.info);
              }
            },
            child:
                const Text('Skip Dose', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteMedicine(
      BuildContext context, MedicineEntity medicine) async {
    final cubit = context.read<MedicineCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Medicine?'),
        content: Text(
          'Are you sure you want to delete "${medicine.name}"?\n\n'
          '• All upcoming alarms and reminder notifications will be cancelled immediately.\n'
          '• Your past adherence and dose history will be safely preserved.',
          style: AppText.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Medicine'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Medicine'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await cubit.deleteMedicine(medicine.id);
      if (context.mounted) {
        showToast(
          context,
          '${medicine.name} deleted and alarms cancelled',
          type: ToastType.info,
          icon: Icons.delete_rounded,
        );
      }
    }
  }

  Widget _buildMedicineOptionsMenu(
      BuildContext context, MedicineEntity medicine,
      {DoseLogEntity? dose}) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: context.textSecondaryColor,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 160),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tooltip: 'Options',
      onSelected: (val) async {
        if (val == 'edit') {
          await context.push(AppRoutes.medicineAdd, extra: medicine);
        } else if (val == 'delete') {
          await _confirmDeleteMedicine(context, medicine);
        } else if (val == 'skip' && dose != null) {
          _showSkipDialog(context, dose);
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              const Text('Edit Schedule'),
            ],
          ),
        ),
        if (dose != null && dose.isPending)
          PopupMenuItem(
            value: 'skip',
            child: Row(
              children: [
                Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 10),
                const Text('Skip This Dose'),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.dangerRed),
              const SizedBox(width: 10),
              Text('Delete Medicine',
                  style: TextStyle(color: AppColors.dangerRed)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicineCubit, MedicineState>(
      builder: (context, state) {
        final cubit = context.read<MedicineCubit>();
        final isToday = DateFormat('yyyy-MM-dd').format(state.selectedDate) ==
            DateFormat('yyyy-MM-dd').format(DateTime.now());

        final doses = state.todayDoses;

        return AppScaffold(
          appBar: KeepRemindAppBar(
            title: _selectedTab == 0
                ? (isToday
                    ? "Today's Medicines"
                    : DateFormat('EEE, dd MMM').format(state.selectedDate))
                : "My Prescriptions",
            subtitle: _selectedTab == 0
                ? '${state.takenCount} taken • ${state.pendingCount} pending'
                : '${state.medicines.length} active prescriptions',
            showBack: true,
            actions: [
              if (_selectedTab == 0)
                CircleIconButton(
                  icon: Icons.calendar_month_rounded,
                  tooltip: 'Select Date',
                  size: 38,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: state.selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 90)),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      cubit.changeSelectedDate(picked);
                    }
                  },
                ),
              const SizedBox(width: 8),
              CircleIconButton(
                icon: Icons.add_rounded,
                tooltip: 'Add Medicine',
                size: 38,
                onTap: () => context.push(AppRoutes.medicineAdd),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildTopPillToggle(context, state),
              Expanded(
                child: _selectedTab == 0
                    ? _buildDailyDosesView(context, state, isToday, doses)
                    : _buildAllPrescriptionsView(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopPillToggle(BuildContext context, MedicineState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 0),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? AppColors.medicineCareColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Daily Doses",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _selectedTab == 0
                        ? Colors.white
                        : context.textSecondaryColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 1),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? AppColors.medicineCareColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "All Prescriptions (${state.medicines.length})",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _selectedTab == 1
                        ? Colors.white
                        : context.textSecondaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyDosesView(BuildContext context, MedicineState state,
      bool isToday, List<DoseLogEntity> doses) {
    final nextDose = state.nextDose;

    if (doses.isEmpty) {
      return EmptyStateView(
        icon: Icons.medication_outlined,
        title: 'No medicines scheduled',
        description: isToday
            ? 'No active medicine doses for today. Tap "+ Add Medicine" to set up your prescription schedule.'
            : 'No scheduled doses for this date.',
        actionLabel: '+ Add Medicine',
        onAction: () => context.push(AppRoutes.medicineAdd),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
      children: [
        // Next Dose Hero Card if applicable
        if (isToday && nextDose != null) ...[
          _buildNextDoseHeroCard(context, nextDose),
          const SizedBox(height: 16),
        ],

        // Summary statistics strip
        _buildStatsRow(context, state),

        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Scheduled Doses (${doses.length})',
              style: AppText.h3.copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...doses.map((dose) => _buildDoseCard(context, dose)),
      ],
    );
  }

  Widget _buildAllPrescriptionsView(BuildContext context, MedicineState state) {
    final medicines = state.medicines;
    if (medicines.isEmpty) {
      return EmptyStateView(
        icon: Icons.medication_outlined,
        title: 'No medicines added yet',
        description:
            'Add your prescribed medicines with dosage, daily timings, and alarm modes.',
        actionLabel: '+ Add Medicine',
        onAction: () => context.push(AppRoutes.medicineAdd),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final med = medicines[index];
        return _buildPrescriptionCard(context, med);
      },
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, MedicineEntity med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.medicineCareColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    med.medicineType.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: AppText.h3.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${med.dosage} • ${med.instructions.label}',
                      style: AppText.bodyMedium.copyWith(
                        color: context.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (med.doctorName != null &&
                        med.doctorName!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Dr. ${med.doctorName}',
                        style: AppText.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildMedicineOptionsMenu(context, med),
            ],
          ),
          const SizedBox(height: 12),
          // Metadata badges row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              // Reminder Mode badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: med.reminderMode == MedicineReminderMode.alarm
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      med.reminderMode == MedicineReminderMode.alarm
                          ? Icons.alarm_rounded
                          : Icons.notifications_active_rounded,
                      size: 13,
                      color: med.reminderMode == MedicineReminderMode.alarm
                          ? AppColors.accent
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      med.reminderMode == MedicineReminderMode.alarm
                          ? 'Persistent Alarm'
                          : 'Notification',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: med.reminderMode == MedicineReminderMode.alarm
                            ? AppColors.accent
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Dates badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.surfaceRaisedColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  med.endDate != null
                      ? 'Till ${med.endDate}'
                      : 'Ongoing Prescription',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Scheduled timings chips
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Timings: ',
                style: AppText.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: med.schedules.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            AppColors.medicineCareColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.medicineCareColor
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        '${_formatTime12Hour(s.doseTime)} (${s.doseLabel ?? ""})',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.medicineCareColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: context.cardBorderColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.dangerRed,
                ),
                onPressed: () => _confirmDeleteMedicine(context, med),
                icon: const Icon(Icons.delete_outline_rounded, size: 17),
                label: const Text('Delete'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                onPressed: () =>
                    context.push(AppRoutes.medicineAdd, extra: med),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text(
                  'Edit Schedule',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextDoseHeroCard(BuildContext context, DoseLogEntity dose) {
    final cubit = context.read<MedicineCubit>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.medicineCareColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.medicineCareColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.alarm_rounded,
                      color: AppColors.medicineCareColor,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'NEXT DOSE',
                      style: TextStyle(
                        color: AppColors.medicineCareColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _formatTime12Hour(dose.scheduledTime),
                style: AppText.timeDisplay,
              ),
              const SizedBox(width: 4),
              _buildMedicineOptionsMenu(context, dose.medicine, dose: dose),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dose.medicine.name,
            style: AppText.h2.copyWith(fontSize: 21),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                dose.medicine.dosage,
                style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.surfaceRaisedColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  dose.medicine.instructions.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.safeGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: const Text(
                    'Mark Taken',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () async {
                    await cubit.markDoseTaken(dose);
                    if (context.mounted) {
                      showToast(
                        context,
                        '${dose.medicine.name} marked as taken!',
                        type: ToastType.success,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: const Icon(Icons.snooze_rounded, size: 18),
                  label: const Text('Snooze'),
                  onPressed: () async {
                    await cubit.snoozeDose(dose, minutes: 15);
                    if (context.mounted) {
                      showToast(
                        context,
                        'Snoozed for 15 minutes',
                        type: ToastType.info,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, MedicineState state) {
    return Row(
      children: [
        _statChip(context, 'Taken', state.takenCount, AppColors.safeGreen),
        const SizedBox(width: 8),
        _statChip(context, 'Pending', state.pendingCount, AppColors.primary),
        const SizedBox(width: 8),
        _statChip(context, 'Skipped', state.skippedCount, AppColors.textMuted),
        const SizedBox(width: 8),
        _statChip(context, 'Unconfirmed', state.unconfirmedCount,
            AppColors.dangerRed),
      ],
    );
  }

  Widget _statChip(BuildContext context, String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.cardBorderColor),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppText.bodySmall.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseCard(BuildContext context, DoseLogEntity dose) {
    final cubit = context.read<MedicineCubit>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.medicineCareColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    dose.medicine.medicineType.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dose.medicine.name,
                      style: AppText.h3.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime12Hour(dose.scheduledTime),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _buildMedicineOptionsMenu(context, dose.medicine,
                          dose: dose),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _statusBadge(dose.status),
                ],
              ),
            ],
          ),

          // Show Action buttons if dose is pending or snoozed
          if (dose.isPending) ...[
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: AppColors.cardBorder.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showSkipDialog(context, dose),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  label: Text(
                    'Skip',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: 6),
                TextButton.icon(
                  onPressed: () async {
                    await cubit.snoozeDose(dose, minutes: 15);
                    if (context.mounted) {
                      showToast(
                        context,
                        'Snoozed for 15 minutes',
                        type: ToastType.info,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.snooze_rounded,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  label: const Text(
                    'Snooze',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.safeGreen,
                    minimumSize: const Size(100, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: () async {
                    await cubit.markDoseTaken(dose);
                    if (context.mounted) {
                      showToast(
                        context,
                        'Marked as taken!',
                        type: ToastType.success,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Taken',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (dose.isTaken && dose.actionTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Confirmed at ${DateFormat('hh:mm a').format(DateTime.parse(dose.actionTime!))}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.safeGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else if (dose.isSkipped && dose.skipReason != null) ...[
            const SizedBox(height: 8),
            Text(
              'Reason: ${dose.skipReason}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(DoseStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case DoseStatus.taken:
        bg = AppColors.safeGreen.withValues(alpha: 0.12);
        fg = AppColors.safeGreen;
        label = 'Taken';
        break;
      case DoseStatus.snoozed:
        bg = AppColors.accent.withValues(alpha: 0.12);
        fg = AppColors.accent;
        label = 'Snoozed';
        break;
      case DoseStatus.skipped:
        bg = Colors.grey.withValues(alpha: 0.12);
        fg = AppColors.textMuted;
        label = 'Skipped';
        break;
      case DoseStatus.unconfirmed:
      case DoseStatus.missed:
        bg = AppColors.dangerRed.withValues(alpha: 0.12);
        fg = AppColors.dangerRed;
        label = 'Unconfirmed';
        break;
      case DoseStatus.pending:
        bg = AppColors.primary.withValues(alpha: 0.12);
        fg = AppColors.primary;
        label = 'Upcoming';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
