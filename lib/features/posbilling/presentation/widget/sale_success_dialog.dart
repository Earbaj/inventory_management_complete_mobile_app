import 'package:flutter/material.dart';
import '../../../../core/services/bluetooth_printer_service.dart';
import '../../domain/entities/sale_entity.dart';

class SaleSuccessDialog extends StatelessWidget {
  final SaleEntity? completedSale;

  const SaleSuccessDialog({super.key, this.completedSale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sale = completedSale;
    final dueAmount = sale?.dueAmount ?? 0.0;
    final paidAmount = sale?.paidAmount ?? 0.0;
    final netTotal = sale?.netTotal ?? 0.0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: dueAmount > 0
                  ? Colors.orange.withValues(alpha: 0.12)
                  : Colors.green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              dueAmount > 0 ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: dueAmount > 0 ? Colors.orange[800] : Colors.green,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            dueAmount > 0 ? 'Sale Saved with Due' : 'Sale Successful!',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            dueAmount > 0
                ? '৳${dueAmount.toStringAsFixed(2)} added to customer due balance.'
                : 'Payment received in full.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: dueAmount > 0 ? Colors.orange[900] : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // INVOICE & BREAKDOWN CARD
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Invoice No:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      sale?.invoiceNo ?? 'INV-2026-00125',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                if (sale?.customer != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Customer:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        sale!.customer!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Net Total:', style: TextStyle(fontSize: 13)),
                    Text(
                      '৳${netTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Paid Amount:', style: TextStyle(fontSize: 13, color: Colors.green)),
                    Text(
                      '৳${paidAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Due Amount:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: dueAmount > 0 ? FontWeight.bold : FontWeight.normal,
                        color: dueAmount > 0 ? Colors.orange[900] : Colors.grey[700],
                      ),
                    ),
                    Text(
                      '৳${dueAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: dueAmount > 0 ? Colors.orange[900] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // THERMAL BLUETOOTH PRINT BUTTON
          if (sale != null)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {
                  BluetoothPrinterService.showPrinterSheet(context, sale: sale);
                },
                icon: const Icon(Icons.print_rounded, color: Colors.blue),
                label: const Text('Print ESC/POS Memo', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
            ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}