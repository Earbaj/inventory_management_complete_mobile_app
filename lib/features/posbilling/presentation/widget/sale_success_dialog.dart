import 'package:flutter/material.dart';
import '../../../../core/services/bluetooth_printer_service.dart';
import '../domain/entities/sale_entity.dart';

class SaleSuccessDialog extends StatelessWidget {
  final SaleEntity? completedSale;

  const SaleSuccessDialog({super.key, this.completedSale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.green, size: 40),
          ),
          const SizedBox(height: 18),
          const Text('Sale Successful!', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'The items have been successfully sold.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('Invoice Number', style: TextStyle(fontSize: 11)),
                const SizedBox(height: 4),
                Text(
                  completedSale?.invoiceNo ?? 'INV-2026-00125',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // THERMAL BLUETOOTH PRINT BUTTON
          if (completedSale != null)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {
                  BluetoothPrinterService.showPrinterSheet(context, sale: completedSale!);
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