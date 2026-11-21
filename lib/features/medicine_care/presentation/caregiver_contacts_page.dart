import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../cubit/medicine_cubit.dart';
import '../cubit/medicine_state.dart';
import '../domain/entities/caregiver_entity.dart';
import '../domain/entities/dose_log_entity.dart';

class CaregiverContactsPage extends StatelessWidget {
  const CaregiverContactsPage({super.key});

  void _showAddEditCaregiverDialog(BuildContext context,
      [CaregiverEntity? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final relationCtrl =
        TextEditingController(text: existing?.relationship ?? 'Son');
    final contactCtrl =
        TextEditingController(text: existing?.phoneOrEmail ?? '');
    int gracePeriod = existing?.gracePeriodMinutes ?? 30;

    final relationships = [
      'Son',
      'Daughter',
      'Spouse',
      'Parent',
      'Doctor',
      'Nurse / Caregiver',
      'Other'
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Link Caregiver' : 'Edit Caregiver'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caregiver Name *',
                  style: AppText.label,
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Rajesh, Anita',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Relationship',
                  style: AppText.label,
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: relationships.contains(relationCtrl.text)
                      ? relationCtrl.text
                      : relationships.first,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: relationships
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => relationCtrl.text = val);
                    }
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  'Phone or Email *',
                  style: AppText.label,
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: contactCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+91 98765 43210 or email@domain.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Grace Period for Alert',
                  style: AppText.label,
                ),
                const SizedBox(height: 4),
                Text(
                  'Caregiver will be alerted if dose is unconfirmed after this time.',
                  style: AppText.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [15, 30, 45, 60].map((mins) {
                    final isSel = gracePeriod == mins;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Text('${mins}m'),
                        selected: isSel,
                        selectedColor:
                            AppColors.medicineCareColor.withValues(alpha: 0.15),
                        backgroundColor: context.surfaceColor,
                        labelStyle: TextStyle(
                          color: isSel
                              ? AppColors.medicineCareColor
                              : AppColors.textSecondary,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSel
                              ? AppColors.medicineCareColor
                              : AppColors.cardBorder,
                        ),
                        onSelected: (val) {
                          if (val) setDialogState(() => gracePeriod = mins);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.medicineCareColor,
                minimumSize: const Size(120, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final contact = contactCtrl.text.trim();
                if (name.isEmpty || contact.isEmpty) {
                  showToast(context, 'Please fill name and contact info',
                      type: ToastType.warning);
                  return;
                }

                final id = existing?.id ?? const Uuid().v4();
                final companion = CaregiverContactsCompanion(
                  id: drift.Value(id),
                  name: drift.Value(name),
                  relationship: drift.Value(relationCtrl.text),
                  phoneOrEmail: drift.Value(contact),
                  gracePeriodMinutes: drift.Value(gracePeriod),
                  notifyUnconfirmed: const drift.Value(true),
                  createdAt: drift.Value(
                    existing?.createdAt ?? DateTime.now().toIso8601String(),
                  ),
                );

                Navigator.pop(ctx);
                await context.read<MedicineCubit>().saveCaregiver(companion);
                if (context.mounted) {
                  showToast(context, 'Caregiver linked successfully!',
                      type: ToastType.success);
                }
              },
              child: const Text(
                'Save Caregiver',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareCaregiverSummary(BuildContext context, MedicineState state) {
    final unconfirmed = state.todayDoses
        .where((d) => d.status == DoseStatus.unconfirmed)
        .toList();
    final buffer = StringBuffer();
    buffer.writeln('📋 KeepRemind - Medication Update');
    buffer.writeln(
        'Today\'s Summary: ${state.takenCount} taken, ${state.pendingCount} pending');

    if (unconfirmed.isNotEmpty) {
      buffer.writeln('\n⚠️ Unconfirmed Doses (beyond grace period):');
      for (final d in unconfirmed) {
        buffer.writeln(
            '• ${d.medicine.name} (${d.medicine.dosage}) scheduled at ${d.scheduledTime} - Dose not confirmed yet');
      }
    } else {
      buffer.writeln('\nAll doses up to this time are in order.');
    }
    buffer.writeln(
        '\n(Note: A missed notification is not proof of skipping. Please check gently with your family member.)');

    Share.share(buffer.toString(), subject: 'Medication Update');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicineCubit, MedicineState>(
      builder: (context, state) {
        final caregivers = state.caregivers;
        final unconfirmedDoses = state.todayDoses
            .where((d) => d.status == DoseStatus.unconfirmed)
            .toList();

        return AppScaffold(
          appBar: KeepRemindAppBar(
            title: 'Family & Caregiver Support',
            subtitle: 'Linked contacts & unconfirmed dose alerts',
            showBack: true,
            actions: [
              CircleIconButton(
                icon: Icons.share_rounded,
                tooltip: 'Share Medication Update',
                size: 38,
                onTap: () => _shareCaregiverSummary(context, state),
              ),
              const SizedBox(width: 8),
              CircleIconButton(
                icon: Icons.person_add_rounded,
                tooltip: 'Add Caregiver',
                size: 38,
                onTap: () => _showAddEditCaregiverDialog(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              // Respectful Caregiver Philosophy Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.infoBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.infoBlue.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: AppColors.infoBlue, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Caregivers receive respectful "Dose not confirmed" notices rather than assuming a dose was missed. Privacy is strictly protected.',
                        style: AppText.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Unconfirmed Doses Alert Box if any
              if (unconfirmedDoses.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.warningOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.warningOrange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Unconfirmed Doses (${unconfirmedDoses.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.warningOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'The following doses passed the grace period without confirmation:',
                        style: AppText.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      ...unconfirmedDoses.map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Text('• ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  '${d.medicine.name} (${d.scheduledTime})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Dose not confirmed',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dangerRed,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Linked Caregivers (${caregivers.length})',
                    style: AppText.h3.copyWith(fontSize: 16),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddEditCaregiverDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (caregivers.isEmpty)
                const EmptyStateView(
                  icon: Icons.family_restroom_outlined,
                  title: 'No caregivers linked',
                  description:
                      'Add a family member, son, daughter, or doctor to receive unconfirmed dose alerts if you ever forget a medicine.',
                )
              else
                ...caregivers.map((cg) => _buildCaregiverCard(context, cg)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCaregiverCard(BuildContext context, CaregiverEntity cg) {
    final cubit = context.read<MedicineCubit>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.medicineCareColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.person_rounded,
                  color: AppColors.medicineCareColor, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cg.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cg.relationship} • ${cg.phoneOrEmail}',
                  style: AppText.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Alerts after ${cg.gracePeriodMinutes} mins grace period',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Edit',
            onPressed: () => _showAddEditCaregiverDialog(context, cg),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.dangerRed, size: 20),
            tooltip: 'Remove',
            onPressed: () async {
              await cubit.deleteCaregiver(cg.id);
              if (context.mounted) {
                showToast(context, 'Caregiver removed', type: ToastType.info);
              }
            },
          ),
        ],
      ),
    );
  }
}
