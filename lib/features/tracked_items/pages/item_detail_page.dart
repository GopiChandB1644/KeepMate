import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../core/storage/file_path_resolver.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/widgets.dart';
import '../cubit/items_cubit.dart';
import '../domain/entities/tracked_item_entity.dart';
import 'add_edit_item_page.dart';
import 'renewal_flow_page.dart';

class ItemDetailPage extends StatelessWidget {
  final TrackedItemEntity item;

  const ItemDetailPage({super.key, required this.item});

  Future<void> _openDocument(BuildContext context, ItemDocument doc) async {
    try {
      final file = await FilePathResolver.resolveRelativePath(doc.relativePath);
      if (await file.exists()) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(doc.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
            content: doc.fileName.toLowerCase().endsWith('.pdf')
                ? const Text('PDF file ready. Previewing document from local storage.')
                : Image.file(file),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ],
          ),
        );
      } else {
        if (!context.mounted) return;
        showToast(
          context,
          'Document file not found on device storage',
          icon: Icons.error_outline_rounded,
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      showToast(
        context,
        'Error opening file: $e',
        icon: Icons.error_outline_rounded,
        type: ToastType.error,
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this item?'),
        content: const Text(
          'This will remove this item and cancel all upcoming reminder alerts. Associated documents will be kept in your vault.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ItemsCubit>().deleteItem(item.id);
              showToast(context, 'Item deleted', icon: Icons.delete_sweep_rounded, type: ToastType.info);
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.dangerRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sub = item.subcategory;

    return Scaffold(
      appBar: KeepRemindAppBar(
        title: item.title,
        subtitle: '${sub.displayName} Details',
        actions: [
          CircleIconButton(
            icon: Icons.edit_outlined,
            size: 38,
            tooltip: 'Edit Details',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditItemPage(existingItem: item),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          CircleIconButton(
            icon: Icons.delete_outline_rounded,
            size: 38,
            iconColor: AppColors.dangerRed,
            tooltip: 'Delete',
            onTap: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(sub.displayName.toUpperCase(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    StatusChip(status: item.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text(item.title, style: AppText.h1),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(item.description!, style: AppText.bodyMedium),
                ],
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.alarm_rounded, color: AppColors.warningOrange, size: 24),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.subcategory == ItemSubcategory.bill ? 'Due Date' : 'Expiry Date',
                          style: AppText.bodySmall,
                        ),
                        Text(
                          item.targetDate != null ? AppDateUtils.formatDisplay(item.targetDate) : 'No date set',
                          style: AppText.h3,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.relativeTimeLabel,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Category-Specific Details Card
          if (item.billDetails != null ||
              item.insuranceDetails != null ||
              item.groceryDetails != null ||
              item.warrantyDetails != null ||
              item.subscriptionDetails != null) ...[
            Text('Details', style: AppText.label),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  if (item.billDetails != null) ...[
                    _detailRow('Provider', item.billDetails!.providerName),
                    if (item.billDetails!.accountNumber != null)
                      _detailRow('Account No', item.billDetails!.accountNumber!),
                    if (item.billDetails!.amount != null)
                      _detailRow('Amount Due', '₹${item.billDetails!.amount!.toStringAsFixed(2)}'),
                    _detailRow('Payment Status', item.billDetails!.paymentStatus.toUpperCase()),
                  ],
                  if (item.insuranceDetails != null) ...[
                    _detailRow('Insurance Company', item.insuranceDetails!.provider),
                    if (item.insuranceDetails!.policyNumber != null)
                      _detailRow('Policy Number', item.insuranceDetails!.policyNumber!),
                    if (item.insuranceDetails!.vehicleNumber != null)
                      _detailRow('Vehicle Reg No', item.insuranceDetails!.vehicleNumber!),
                    if (item.insuranceDetails!.premiumAmount != null)
                      _detailRow('Premium Amount', '₹${item.insuranceDetails!.premiumAmount!.toStringAsFixed(2)}'),
                  ],
                  if (item.groceryDetails != null) ...[
                    _detailRow('Storage Location', StorageLocation.fromCode(item.groceryDetails!.storageLocation).label),
                    _detailRow('Quantity Remaining', '${item.groceryDetails!.quantityRemaining} ${item.groceryDetails!.quantityUnit}'),
                    if (item.groceryDetails!.batchNumber != null)
                      _detailRow('Batch Number', item.groceryDetails!.batchNumber!),
                  ],
                  if (item.warrantyDetails != null) ...[
                    if (item.warrantyDetails!.seller != null)
                      _detailRow('Store / Seller', item.warrantyDetails!.seller!),
                    if (item.warrantyDetails!.purchaseAmount != null)
                      _detailRow('Purchase Price', '₹${item.warrantyDetails!.purchaseAmount!.toStringAsFixed(2)}'),
                  ],
                  if (item.subscriptionDetails != null) ...[
                    _detailRow('Billing Cycle', item.subscriptionDetails!.billingCycle.toUpperCase()),
                    if (item.subscriptionDetails!.amount != null)
                      _detailRow('Price', '₹${item.subscriptionDetails!.amount!.toStringAsFixed(2)}'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Quick Action Buttons
          if (item.subcategory == ItemSubcategory.bill && item.status != ItemStatus.completed) ...[
            ElevatedButton.icon(
              onPressed: () {
                context.read<ItemsCubit>().markPaid(item.id);
                context.pop();
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Mark as Paid'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.safeGreen),
            ),
            const SizedBox(height: 12),
          ],

          if (item.subcategory == ItemSubcategory.grocery &&
              item.status != ItemStatus.consumed &&
              item.status != ItemStatus.discarded) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<ItemsCubit>().markConsumed(item.id);
                      context.pop();
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Used / Consumed'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.safeGreen),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<ItemsCubit>().markDiscarded(item.id);
                      context.pop();
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Discarded'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          if (item.subcategory == ItemSubcategory.insurance ||
              item.subcategory == ItemSubcategory.warranty ||
              item.subcategory == ItemSubcategory.document) ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RenewalFlowPage(item: item)),
                );
              },
              icon: const Icon(Icons.autorenew_rounded),
              label: const Text('Renew This Policy / Document'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
            const SizedBox(height: 20),
          ],

          // Documents section
          Text('Attached Documents & Receipts (${item.documents.length})', style: AppText.label),
          const SizedBox(height: 10),
          if (item.documents.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('No files attached. You can edit this item to attach invoices or certificates.'),
            )
          else
            ...item.documents.map((doc) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    doc.fileName.toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(doc.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${(doc.fileSize / 1024).toStringAsFixed(1)} KB'),
                  trailing: const Icon(Icons.visibility_rounded),
                  onTap: () => _openDocument(context, doc),
                ),
              );
            }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.bodyMedium),
          Text(value, style: AppText.h3),
        ],
      ),
    );
  }
}
