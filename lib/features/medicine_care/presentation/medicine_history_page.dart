import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../domain/entities/dose_log_entity.dart';
import '../domain/repositories/medicine_repository.dart';

class MedicineHistoryPage extends StatefulWidget {
  final Future<List<DoseLogEntity>>? historyFuture;

  const MedicineHistoryPage({super.key, this.historyFuture});

  @override
  State<MedicineHistoryPage> createState() => _MedicineHistoryPageState();
}

class _MedicineHistoryPageState extends State<MedicineHistoryPage> {
  String _selectedFilter = 'all'; // all, taken, skipped
  late Future<List<DoseLogEntity>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = widget.historyFuture ??
        context.read<MedicineRepository>().getAllDoseHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KeepRemindAppBar(
        title: 'Medicine History',
        subtitle: 'Adherence tracking & dose records',
        showBack: true,
      ),
      body: FutureBuilder<List<DoseLogEntity>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return const EmptyStateView(
              icon: Icons.history_rounded,
              title: 'No dose records yet',
              description:
                  'Your logged doses and medication adherence history will appear here once you take or skip scheduled doses.',
            );
          }

          final takenCount =
              history.where((d) => d.status == DoseStatus.taken).length;
          final skippedCount =
              history.where((d) => d.status == DoseStatus.skipped).length;
          final totalActioned = takenCount + skippedCount;
          final adherencePercent = totalActioned > 0
              ? ((takenCount / totalActioned) * 100).round()
              : 100;

          final filtered = history.where((d) {
            if (_selectedFilter == 'taken') {
              return d.status == DoseStatus.taken;
            }
            if (_selectedFilter == 'skipped') {
              return d.status == DoseStatus.skipped;
            }
            return true;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              // Adherence Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            value: totalActioned > 0
                                ? (takenCount / totalActioned)
                                : 1.0,
                            strokeWidth: 6,
                            backgroundColor: AppColors.cardBorder,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.safeGreen),
                          ),
                        ),
                        Text(
                          '$adherencePercent%',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Medication Adherence',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$takenCount doses taken • $skippedCount skipped',
                            style: AppText.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Filter Chips
              Row(
                children: [
                  _filterChip('all', 'All Records (${history.length})'),
                  const SizedBox(width: 8),
                  _filterChip('taken', 'Taken ($takenCount)'),
                  const SizedBox(width: 8),
                  _filterChip('skipped', 'Skipped ($skippedCount)'),
                ],
              ),

              const SizedBox(height: 16),

              ...filtered.map((item) => _buildHistoryCard(item)),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String code, String label) {
    final isSel = _selectedFilter == code;
    return ChoiceChip(
      label: Text(label),
      selected: isSel,
      selectedColor: AppColors.medicineCareColor.withValues(alpha: 0.18),
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
        color: isSel ? AppColors.medicineCareColor : AppColors.textSecondary,
      ),
      side: BorderSide(
          color: isSel ? AppColors.medicineCareColor : AppColors.cardBorder),
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = code);
      },
    );
  }

  Widget _buildHistoryCard(DoseLogEntity dose) {
    final isTaken = dose.status == DoseStatus.taken;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(
            isTaken ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isTaken ? AppColors.safeGreen : AppColors.textMuted,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dose.medicine.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '${dose.scheduledDate} at ${dose.scheduledTime} • ${dose.medicine.dosage}',
                  style: AppText.bodySmall,
                ),
                if (!isTaken && dose.skipReason != null) ...[
                  const SizedBox(height: 2),
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
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isTaken
                  ? AppColors.safeGreen.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isTaken ? 'Taken' : 'Skipped',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isTaken ? AppColors.safeGreen : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
