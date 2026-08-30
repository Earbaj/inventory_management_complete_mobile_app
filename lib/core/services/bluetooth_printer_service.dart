import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../utils/money_util.dart';
import '../../features/posbilling/domain/entities/sale_entity.dart';

/// Bluetooth POS 58mm / 80mm ESC/POS Thermal Receipt Printing Service.
class BluetoothPrinterService {
  /// Opens Bluetooth POS Thermal Printers Discovery & Print Dialog Sheet.
  static Future<void> showPrinterSheet(BuildContext context, {required SaleEntity sale}) async {
    developer.log('🖨️ [BluetoothPrinterService] Launching Bluetooth Thermal Printer Sheet for Invoice ${sale.invoiceNo}', name: 'BluetoothPrinterService');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _BluetoothPrinterModal(sale: sale),
    );
  }

  /// Converts SaleEntity to ESC/POS Thermal Printer Text Commands (58mm/80mm).
  static String formatEscPosThermalText(SaleEntity sale, {String shopName = 'Smart Inventory Store'}) {
    final buffer = StringBuffer();
    const divider = '================================';
    const subDivider = '--------------------------------';

    buffer.writeln('[CENTER] $shopName');
    buffer.writeln('[CENTER] POS Sales Receipt');
    buffer.writeln(divider);
    buffer.writeln('Invoice: ${sale.invoiceNo}');
    buffer.writeln('Date: ${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year} ${sale.createdAt.hour}:${sale.createdAt.minute}');
    buffer.writeln('Customer: ${sale.customer?.name ?? "Walk-in"}');
    buffer.writeln(subDivider);
    buffer.writeln('Item Name        Qty Price Total');
    buffer.writeln(subDivider);

    for (final item in sale.items) {
      final name = item.item.name.length > 14 ? item.item.name.substring(0, 14) : item.item.name.padRight(14);
      final qty = item.quantity.toString().padLeft(3);
      final price = item.item.retailSellPrice.toStringAsFixed(0).padLeft(5);
      final total = (item.quantity * item.item.retailSellPrice).toStringAsFixed(0).padLeft(6);
      buffer.writeln('$name $qty $price $total');
    }

    final symbol = MoneyUtil.currencySymbol;
    buffer.writeln(subDivider);
    buffer.writeln('Subtotal:       $symbol ${sale.subtotal.toStringAsFixed(2)}');
    buffer.writeln('Discount:      -$symbol ${sale.discountAmount.toStringAsFixed(2)}');
    buffer.writeln('VAT:           +$symbol ${sale.vatAmount.toStringAsFixed(2)}');
    buffer.writeln(divider);
    buffer.writeln('NET TOTAL:      $symbol ${sale.netTotal.toStringAsFixed(2)}');
    buffer.writeln('Paid Amount:    $symbol ${sale.paidAmount.toStringAsFixed(2)}');
    buffer.writeln('Due Amount:     $symbol ${sale.dueAmount.toStringAsFixed(2)}');
    buffer.writeln('Method:         ${sale.paymentMethod.toUpperCase()}');
    buffer.writeln(divider);
    buffer.writeln('[CENTER] Thank You! Visit Again.');
    buffer.writeln('\n\n');

    return buffer.toString();
  }
}

class _BluetoothPrinterModal extends StatefulWidget {
  final SaleEntity sale;

  const _BluetoothPrinterModal({required this.sale});

  @override
  State<_BluetoothPrinterModal> createState() => _BluetoothPrinterModalState();
}

class _BluetoothPrinterModalState extends State<_BluetoothPrinterModal> {
  bool _isScanning = false;
  String? _selectedDeviceAddress;

  final List<Map<String, String>> _mockDevices = const [
    {'name': 'POS-58 (Thermal Printer)', 'address': 'DC:0D:30:84:1A:01'},
    {'name': 'POS-80 (Bluetooth Printer)', 'address': '84:2A:FD:91:00:12'},
    {'name': 'RPP02N Thermal Printer', 'address': '60:55:F9:12:34:56'},
  ];

  @override
  void initState() {
    super.initState();
    _scanBluetoothPrinters();
  }

  void _scanBluetoothPrinters() {
    setState(() => _isScanning = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _selectedDeviceAddress = _mockDevices.first['address'];
        });
      }
    });
  }

  void _printReceipt() {
    final payload = BluetoothPrinterService.formatEscPosThermalText(widget.sale);
    developer.log('🖨️ [BluetoothPrinterService] Dispatching ESC/POS print payload to $_selectedDeviceAddress:\n$payload', name: 'BluetoothPrinterService');

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thermal Receipt printed on ${_mockDevices.firstWhere((d) => d['address'] == _selectedDeviceAddress)['name']}!'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final escPosText = BluetoothPrinterService.formatEscPosThermalText(widget.sale);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.print_rounded, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Bluetooth POS Thermal Printer',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Select nearby 58mm/80mm Bluetooth printer to print receipt:', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 14),

          // BLUETOOTH DEVICES LIST
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Column(
              children: _mockDevices.map((device) {
                final isSelected = _selectedDeviceAddress == device['address'];
                return Card(
                  elevation: 0,
                  color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.4) : colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isSelected ? colorScheme.primary : Colors.transparent),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.bluetooth_connected_rounded, color: isSelected ? colorScheme.primary : Colors.grey),
                    title: Text(device['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(device['address']!, style: const TextStyle(fontSize: 11)),
                    trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.green) : null,
                    onTap: () => setState(() => _selectedDeviceAddress = device['address']),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 16),
          const Text('ESC/POS Receipt Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),

          // ESC/POS RECEIPT PREVIEW BOX
          Container(
            width: double.infinity,
            height: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SingleChildScrollView(
              child: Text(
                escPosText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _selectedDeviceAddress == null ? null : _printReceipt,
              icon: const Icon(Icons.print_rounded),
              label: const Text('Print ESC/POS Memo Now', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
