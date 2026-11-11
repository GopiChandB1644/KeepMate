import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/utils/date_utils.dart';
import '../cubit/items_cubit.dart';
import '../domain/entities/tracked_item_entity.dart';

class RenewalFlowPage extends StatefulWidget {
  final TrackedItemEntity item;

  const RenewalFlowPage({super.key, required this.item});

  @override
  State<RenewalFlowPage> createState() => _RenewalFlowPageState();
}

class _RenewalFlowPageState extends State<RenewalFlowPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _docNumberController;
  late final TextEditingController _amountController;
  DateTime? _newExpiryDate;
  DateTime? _newStartDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _docNumberController = TextEditingController(
      text: widget.item.insuranceDetails?.policyNumber ??
          widget.item.documentDetails?.documentNumber ??
          '',
    );
    _amountController = TextEditingController(
      text: widget.item.insuranceDetails?.premiumAmount?.toString() ??
          widget.item.billDetails?.amount?.toString() ??
          '',
    );
    final oldExpiry = widget.item.expiryDate ?? DateTime.now();
    _newStartDate = oldExpiry;
    _newExpiryDate = DateTime(oldExpiry.year + 1, oldExpiry.month, oldExpiry.day);
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _newExpiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2045),
    );
    if (picked != null) {
      setState(() => _newExpiryDate = picked);
    }
  }

  Future<void> _submitRenewal() async {
    if (!_formKey.currentState!.validate() || _newExpiryDate == null) return;
    setState(() => _isSaving = true);

    final cubit = context.read<ItemsCubit>();
    final parsedAmount = double.tryParse(_amountController.text.trim());

    await cubit.renewItem(
      oldItemId: widget.item.id,
      newExpiryDate: _newExpiryDate!,
      newStartDate: _newStartDate,
      newDocumentNumber: _docNumberController.text.trim().isEmpty ? null : _docNumberController.text.trim(),
      newAmount: parsedAmount,
    );

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Successfully renewed! Previous record safely archived in history.'),
          backgroundColor: AppColors.safeGreen,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Renew ${widget.item.title}'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Your old records & documents remain safely saved in history. A fresh active cycle will be created.',
                        style: AppText.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('New Expiry / Validity Date *', style: AppText.label),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_available_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _newExpiryDate != null ? AppDateUtils.formatDisplay(_newExpiryDate) : 'Select date',
                        style: AppText.bodyLarge,
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('New Policy / Certificate / Document No', style: AppText.label),
              const SizedBox(height: 6),
              TextFormField(
                controller: _docNumberController,
                decoration: const InputDecoration(hintText: 'e.g. POL-2027-8910'),
              ),
              const SizedBox(height: 20),
              Text('Renewal Fee / Premium Amount (₹)', style: AppText.label),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'e.g. 5200'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _submitRenewal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Confirm Renewal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
