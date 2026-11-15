import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../cubit/medicine_cubit.dart';
import '../cubit/medicine_state.dart';
import '../domain/entities/dose_log_entity.dart';

class TodaySchedulePage extends StatelessWidget {
  const TodaySchedulePage({super.key});

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
            Text('Why is ${dose.medicine.name} being skipped?',
                style: AppText.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: commonReasons.map((r) {
                return ActionChip(
                  label: Text(r, style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    reasonController.text = r;
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Enter reason or select above',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicineCubit, MedicineState>(
      builder: (context, state) {
        final cubit = context.read<MedicineCubit>();
        final isToday = DateFormat('yyyy-MM-dd').format(state.selectedDate) ==
            DateFormat('yyyy-MM-dd').format(DateTime.now());

        final doses = state.todayDoses;
        final nextDose = state.nextDose;

        return Scaffold(
          appBar: KeepRemindAppBar(
            title: isToday
                ? "Today's Medicines"
                : DateFormat('EEE, dd MMM').format(state.selectedDate),
            subtitle:
                '${state.takenCount} taken • ${state.pendingCount} pending',
            showBack: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_rounded),
                tooltip: 'Select Date',
                onPressed: () async {
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
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add Medicine',
                onPressed: () => context.push(AppRoutes.medicineAdd),
              ),
            ],
          ),
          body: doses.isEmpty
              ? EmptyStateView(
                  icon: Icons.medication_rounded,
                  title: 'No medicines scheduled',
                  description: isToday
                      ? 'No active medicine doses for today. Tap "+ Add Medicine" to set up your prescription schedule.'
                      : 'No scheduled doses for this date.',
                  actionLabel: '+ Add Medicine',
                  onAction: () => context.push(AppRoutes.medicineAdd),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                  children: [
                    // Next Dose Hero Card if applicable
                    if (isToday && nextDose != null) ...[
                      _buildNextDoseHeroCard(context, nextDose),
                      const SizedBox(height: 20),
                    ],

                    // Summary statistics strip
                    _buildStatsRow(state),

                    const SizedBox(height: 20),

                    Text('All Scheduled Doses', style: AppText.h3),
                    const SizedBox(height: 12),

                    ...doses.map((dose) => _buildDoseCard(context, dose)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildNextDoseHeroCard(BuildContext context, DoseLogEntity dose) {
    final cubit = context.read<MedicineCubit>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.medicineCareColor,
            AppColors.medicineCareColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.medicineCareColor.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.alarm_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'NEXT DOSE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _formatTime12Hour(dose.scheduledTime),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dose.medicine.name,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${dose.medicine.dosage} • ${dose.medicine.instructions.label}',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.medicineCareColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Mark Taken',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    await cubit.markDoseTaken(dose);
                    if (context.mounted) {
                      showToast(
                          context, '${dose.medicine.name} marked as taken!',
                          type: ToastType.success);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.2),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await cubit.snoozeDose(dose, minutes: 15);
                  if (context.mounted) {
                    showToast(context, 'Snoozed for 15 minutes',
                        type: ToastType.info);
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.snooze_rounded, size: 16),
                    SizedBox(width: 4),
                    Text('Snooze'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(MedicineState state) {
    return Row(
      children: [
        _statChip('Taken', state.takenCount, AppColors.safeGreen),
        const SizedBox(width: 8),
        _statChip('Pending', state.pendingCount, AppColors.infoBlue),
        const SizedBox(width: 8),
        _statChip('Skipped', state.skippedCount, AppColors.textMuted),
        const SizedBox(width: 8),
        _statChip('Unconfirmed', state.unconfirmedCount, AppColors.dangerRed),
      ],
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseCard(BuildContext context, DoseLogEntity dose) {
    final cubit = context.read<MedicineCubit>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.medicineCareColor.withValues(alpha: 0.12),
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
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
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
                  Text(
                    _formatTime12Hour(dose.scheduledTime),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
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
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showSkipDialog(context, dose),
                  icon: Icon(Icons.close_rounded,
                      size: 16, color: AppColors.textMuted),
                  label: Text('Skip',
                      style: TextStyle(color: AppColors.textMuted)),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () async {
                    await cubit.snoozeDose(dose, minutes: 15);
                    if (context.mounted) {
                      showToast(context, 'Snoozed for 15 minutes',
                          type: ToastType.info);
                    }
                  },
                  icon: const Icon(Icons.snooze_rounded,
                      size: 16, color: AppColors.accent),
                  label: const Text('Snooze',
                      style: TextStyle(color: AppColors.accent)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.safeGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () async {
                    await cubit.markDoseTaken(dose);
                    if (context.mounted) {
                      showToast(context, 'Marked as taken!',
                          type: ToastType.success);
                    }
                  },
                  icon: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16),
                  label: const Text('Taken',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ] else if (dose.isTaken && dose.actionTime != null) ...[
            const SizedBox(height: 6),
            Text(
              'Confirmed at ${DateFormat('hh:mm a').format(DateTime.parse(dose.actionTime!))}',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.safeGreen,
                  fontWeight: FontWeight.w600),
            ),
          ] else if (dose.isSkipped && dose.skipReason != null) ...[
            const SizedBox(height: 6),
            Text(
              'Reason: ${dose.skipReason}',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic),
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
        bg = AppColors.safeGreen.withValues(alpha: 0.15);
        fg = AppColors.safeGreen;
        label = 'Taken';
        break;
      case DoseStatus.snoozed:
        bg = AppColors.accent.withValues(alpha: 0.15);
        fg = AppColors.accent;
        label = 'Snoozed';
        break;
      case DoseStatus.skipped:
        bg = Colors.grey.withValues(alpha: 0.15);
        fg = AppColors.textMuted;
        label = 'Skipped';
        break;
      case DoseStatus.unconfirmed:
      case DoseStatus.missed:
        bg = AppColors.dangerRed.withValues(alpha: 0.15);
        fg = AppColors.dangerRed;
        label = 'Unconfirmed';
        break;
      case DoseStatus.pending:
        bg = AppColors.infoBlue.withValues(alpha: 0.15);
        fg = AppColors.infoBlue;
        label = 'Upcoming';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
